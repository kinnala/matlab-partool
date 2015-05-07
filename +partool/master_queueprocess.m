function nsent=master_queueprocess(pool)
% Find out if there exist free workers.
%  - If yes, then send them tasks from the queue.
%  - If no, then do nothing.
%
% Syntax:
%   nsent=partool.master_queueprocess(poll) 
%
cd(pool.directory);

freeworkers={};

for itr=1:pool.nw
    if exist(['partool_worker_',pool.workers{itr},'_init.mat'],'file')~=2 && ...
        exist(['partool_worker_',pool.workers{itr},'_output.mat'],'file')~=2 && ...
        exist(['partool_worker_',pool.workers{itr},'_task.mat'],'file')~=2 
        % is free
        freeworkers{end+1}=pool.workers{itr};
    end
end

if length(freeworkers)==0
    % no free workers; do nothing
    return
end

if ~isfield(pool,'queue')
    error('partool.master_queueprocess: No queue variable set in ''pool''!');
end

% send tasks to free workers
N=1;
for itr=1:length(freeworkers)
    if itr>length(pool.queue)
        break
    end
    taskstruct=pool.queue{itr};
    save(['partool_worker_',freeworkers{itr},'_task.mat'],'taskstruct');
    N=N+1;
end

nsent=N-1;
display(['partool: Sent ',num2str(nsent),' tasks to workers!']);

% remove sent tasks from queue
pool.queue=pool.queue(N:end);
