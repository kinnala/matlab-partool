function slave_start(directory)
% Start a partool slave.
%
% Syntax:
%   partool.slave_start(directory)

% change directory
cd(directory)
% get name of the machine (Linux only)
name=evalc('!hostname');
% remove final '\n'
name=name(1:(end-1));
% publish the worker through filesystem
eval(['!touch partool_worker_',name]);

% how long to wait between subsequent filesystem reads?
nsec=2;
% go into init loop
display('partool: Worker started, waiting for initialization commands ...');
revstr='';
nth=0;
barwidth=5;
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
workerdata=initstruct.initfun(id); % returns struct
% remove partool_worker_<name>_init.mat when done
eval(['!rm partool_worker_',name,'_init.mat']);
display('partool: Worker successfully initialized!');

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
        catch
            display('partool: ERROR! Task threw an expection.');
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
