function data=example_job_init(id)
% 'id' runs from 1 to number-of-workers

% the contents of 'data' are available when performing later tasks.
data.A=id*rand(10);
