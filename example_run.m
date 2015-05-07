% this example demonstrates how SPMD paradigm is used.

% use current folder and initialize with @example_job_init
pool=partool.master_init('.',@example_job_init);

nruns=3;

x=ones(10,1);

for itr=1:nruns
    display(['*** Run number ',num2str(itr),' starting ***']);
    idata=struct;
    idata.x=x;
    odata=partool.master_sendtask(pool,@example_job_task,idata);
    y=zeros(10,1);
    for jtr=1:pool.nw
        if odata{jtr}.done==1
            y=y+odata{jtr}.y;
        else
            display(['Worker ',pool.workers{jtr},' reported failure!']);
        end
    end
end

