function pool=master_init(initfun)
% Initialize master node. Communication directory is 'pwd'!
%
% Syntax:
%   pool=partool.master_init(initfun)
%
% where
%   initfun   -- anonymous function to initialize slaves (see below)
%
%   pool      -- a variable used to identify the parallel pool
%
% The initilization function 'initfun' must take
% one argument (slave id == integer) and output
% one struct containing the worker data.

% change directory and find workers
files=dir('partool_worker*');
nw=0;
% put found workers to a cell array
for file=files'
    workers{nw+1}=file.name(16:end);
    nw=nw+1;
end
if nw==0
    error('partool: No workers found! Quitting initialization.');
    return
end
display(['partool: Discovered ',num2str(nw),...
         ' workers. Sending out the initialization tasks ...']);

% send initialization tasks to slaves
for itr=1:nw
    initstruct=struct;
    initstruct.id=itr;
    initstruct.initfun=initfun;
    save(['partool_worker_',workers{itr},'_init.mat'],'initstruct');
end

nsec=2;
% wait for initialization to succee; 0 = running, 1 = done
rdy=zeros(1,nw);
revstr='';
while 1
    pause(nsec+rand);
    for itr=1:nw
        % partool_worker_init.mat is removed by slave upon completion
        if exist(['partool_worker_',workers{itr},'_init.mat'],'file')~=2
            rdy(itr)=1;
        end
    end
    % print status
    msg=['partool: Initialization status ',num2str(sum(rdy)),'/',num2str(nw),'; '];
    for itr=1:nw
        msg=[msg workers{itr}];
        msg=[msg '('];
        if rdy(itr)
            msg=[msg '*'];
        else
            msg=[msg ' '];
        end
        msg=[msg ') '];
    end
    fprintf([revstr,msg]);
    revstr=repmat(sprintf('\b'),1,length(msg));
    % check if all done
    if sum(rdy)==nw
        msg=sprintf('\npartool: All initialization tasks completed!\n');
        fprintf(msg);
        break
    end
end

% save data to pool-struct
pool=partool.Pool;
pool.workers=workers;

end

