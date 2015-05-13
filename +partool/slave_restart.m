function slave_restart(directory)
% Restart the worker and send failure to master.
% NOTE! Global variable 'workerdata' is used to initialize worker if exists.
%
% Syntax:
%   partool.slave_restart(directory)
name=evalc('!hostname');
name=name(1:(end-1));
odata.done=0;
save(['partool_worker_',name,'_output.mat'],'odata');
eval(['!rm partool_worker_',name,'_task.mat']);
display('partool: Sent failure to master. Restarting slave ...');
partool.slave_start('restart');
