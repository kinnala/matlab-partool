function [owdata,odata]=example_job_task(id,iwdata,idata)
% 'id' runs from 1 to number-of-workers
% 'iwdata' is worker data struct from initialization and/or previous tasks
% 'idata' is task data that is sent from the master

% no need to modify worker data; just pass it on
owdata=iwdata;

% multiply with the initialized matrix and sleep a while
odata.y=iwdata.A*idata.x;
pause(5*rand);

% set odata.done=1 to inform master that the task is completed.
% if exception is thrown by the task, then 'partool.start_slave' sets odata.done=0.
odata.done=1;
