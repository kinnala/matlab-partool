function npool=master_queuetask(pool,task,idata)
% Add a task to queue.
%
% Syntax:
%   npool=partool.master_queuetask(pool,task,idata)
%
if ~isfield(pool,'queue')
    pool.queue={};
end

% add task to queue
taskstruct=struct;
taskstruct.task=task;
taskstruct.idata=idata;
pool.queue{end+1}=taskstruct;
npool=pool;
