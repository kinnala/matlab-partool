function odata=master_sendtask(pool,task,idata)
% Send a task to all slaves.
%
% Syntax:
%
%   odata=partool.master_sendtask(pool,task,idata)
%
% where
%
%   pool    -- the parallel pool from partool_master_init
%   task    -- the anonymous function defining the task (see below)
%   idata   -- struct with input data for slaves
%
%   odata   -- struct with output data from slaves
%
% The task function 'task' must have
%   * 3 input arguments (id,inputworkerdata,idata)
%   * 2 output arguments (outputworkerdata,odata)
% Struct 'idata' is sent to slaves and given to the tasks
% as third input parameter. Data in 'inputworkerdata' is
% saved per slave basis.

cd(pool.directory);

for itr=1:pool.nw
    taskstruct=struct;
    taskstruct.task=task;
    taskstruct.idata=idata;
    save(['partool_worker_',pool.workers{itr},'_task.mat'],'taskstruct');
end
display('partool: Tasks sent! Waiting for output ...');

nsec=2;
% wait for task to succee; 0 = running, 1 = done
rdy=zeros(1,pool.nw);
revstr='';
while 1
    pause(nsec+rand);
    for itr=1:pool.nw
        if exist(['partool_worker_',pool.workers{itr},'_output.mat'],'file')==2
            rdy(itr)=1;
            h=load(['partool_worker_',pool.workers{itr},'_output.mat']);
            odata{itr}=h.odata;
            eval(['!rm partool_worker_',pool.workers{itr},'_output.mat']);
        end
    end
    % print status
    msg=['partool: Task status ',num2str(sum(rdy)),'/',num2str(pool.nw),'; '];
    for itr=1:pool.nw
        msg=[msg pool.workers{itr}];
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
    if sum(rdy)==pool.nw
        msg=sprintf('\npartool: All tasks completed!\n');
        fprintf(msg);
        break
    end
end

end
