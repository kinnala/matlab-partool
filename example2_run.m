% this example demonstrates queued distribution of tasks

pool=partool.master_init('.',@example_job_init);

ntasks=10;

% add all tasks to queue
for itr=1:ntasks
    idata=struct;
    idata.x=ones(10,1);
    partool.master_queuetask(pool,@example_job_task,idata);
end

done=0;

ncomplete=0;

while ~done
    pause(2);
    partool.master_queueprocess(pool);
    [odata,ids]=partool.master_checkoutput(pool);
    if length(ids)~=0
        for itr=ids
            ncomplete=ncomplete+1;
        end
        display(['Already completed ',num2str(ncomplete),'tasks!']);
    end
    if ncomplete==ntasks
        display('All tasks done!');
    end
end
