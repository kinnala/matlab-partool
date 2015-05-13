function slave_start(restartflag)
% Start a partool slave.
% NOTE! Saves slave data to global variable 'workerdata'.
%
% Syntax:
%   partool.slave_start()
global workerdata
global id

% not restart
if nargin==0
    workerdata=[];
end
% get name of the machine (Linux only)
name=evalc('!hostname');
% remove final '\n'
name=name(1:(end-1));
% publish the worker through filesystem
if exist(['partool_worker_',name],'file')~=2
    eval(['!touch partool_worker_',name]);
end

% how long to wait between subsequent filesystem reads?
nsec=1;
% width of the wait bar
barwidth=8;

if ~isstruct(workerdata)
    % go into init loop
    display('partool: Worker started, waiting for initialization commands ...');
    revstr='';
    nth=0;
    while 1
        pause(nsec+rand);
        if exist(['partool_worker_',name,'_init.mat'],'file')==2
            break
        end
        % display waitbar
        msg=['[',repmat(sprintf('-'),1,nth),'*',repmat(sprintf('-'),1,barwidth-nth),']'];
        fprintf([revstr,msg]);
        revstr=repmat(sprintf('\b'),1,length(msg));
        nth=nth+1;
        if nth>barwidth
            nth=0;
        end
    end
    display(' ');
    display('partool: Initialization commands found! Initializing worker ...');
    h=load(['partool_worker_',name,'_init.mat']);
    initstruct=h.initstruct;
    id=initstruct.id;
    % compute initial data
    try
        workerdata=initstruct.initfun(id); % returns struct
    catch
        display('partool: ERROR! Initialization task threw an exception. Exiting ...');
        return
    end
    % remove partool_worker_<name>_init.mat when done
    eval(['!rm partool_worker_',name,'_init.mat']);
    display('partool: Worker successfully initialized!');
end

% go into processing loop
display('partool: Waiting for tasks ...');
revstr='';
nth=0;
while 1
    pause(nsec+rand);
    % check if incoming task exists
    if exist(['partool_worker_',name,'_task.mat'],'file')==2
        display(' ');
        h=load(['partool_worker_',name,'_task.mat']);
        taskstruct=h.taskstruct;
        % if the task contains field 'kill' => quit
        if isfield(taskstruct,'kill')
            display('partool: Received kill!');
            eval(['!rm partool_worker_',name,'_task.mat']);
            eval(['!rm partool_worker_',name]);
            break
        else
            display('partool: Task received! Performing ...');
        end
        % run the task
        try
            [workerdata,odata]=taskstruct.task(id,workerdata,taskstruct.idata);
        catch err
            display('partool: ERROR! Task threw the following expection;');
            display(getReport(err));
            odata.done=0; 
        end
        save(['partool_worker_',name,'_output.mat'],'odata');
        eval(['!rm partool_worker_',name,'_task.mat']);
        display('partool: Task done! Waiting for another task ...');
    end
    % display waitbar
    msg=['[',repmat(sprintf('-'),1,nth),'*',repmat(sprintf('-'),1,barwidth-nth),']'];
    fprintf([revstr,msg]);
    revstr=repmat(sprintf('\b'),1,length(msg));
    nth=nth+1;
    if nth>barwidth
        nth=0;
    end
end

display('partool: Worker exiting.');
   
end
