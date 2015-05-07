function [odata,ids]=master_checkoutput(pool)
% Find out if some workers have completed.
%
% Syntax:
%   [odata,ids]=partool.master_checkoutput(pool)
%
% where
%   pool   --- the parallel pool
%
%   odata  --- data outputted by tasks (cell array)
%   ids    --- worker ids of the corresponding entries in 'odata'
cd(pool.directory);

odata={};
ids=[];

for itr=1:pool.nw
    if exist(['partool_worker_',pool.workers{itr},'_output.mat'],'file')==2
        h=load(['partool_worker_',pool.workers{itr},'_output.mat']);
        odata{end+1}=h.odata;
        ids=[ids itr];
        eval(['!rm partool_worker_',pool.workers{itr},'_output.mat']);
    end
end
