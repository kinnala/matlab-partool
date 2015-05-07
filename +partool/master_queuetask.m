function npool=master_queuetask(pool,task,idata)
% Add a task to queue.
%
% Syntax:
%   npool=partool.master_queuetask(pool,task,idata)
%
npool=pool;
if ~isfield(npool,'queue')
    npool.queue={};
end

% add task to queue
taskstruct=struct;
taskstruct.task=task;
taskstruct.idata=idata;
npool.queue{end+1}=taskstruct;
