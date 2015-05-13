function master_queuetask(pool,task,idata)
% Add a task to queue.
%
% Syntax:
%   partool.master_queuetask(pool,task,idata)
%

% add task to queue
taskstruct=struct;
taskstruct.task=task;
taskstruct.idata=idata;
pool.queue{end+1}=taskstruct;
