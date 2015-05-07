function kill(pool)
% Send kill tasks to all workers.
% Syntax:
%   partool.kill(pool)

for itr=1:length(pool.workers)
    taskstruct=struct;
    taskstruct.kill=1;
    save(['partool_worker_',pool.workers{itr},'_task.mat'],'taskstruct');
end

display('partool: Killing all slaves!');

end
