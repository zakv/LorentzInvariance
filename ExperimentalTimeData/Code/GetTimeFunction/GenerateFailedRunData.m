oldDir = cd('../../DataSets');
load('AttemptedEntryTimeData');
cd(oldDir);

t=event_time();
run = t.run('all','all',0);

entryRun = entryTimes(:,2);
iMax = numel(entryRun);
jMax = numel(run);
k = 0;
failedRunData = zeros(size(entryTimes));
check=zeros(size(entryRun));

for i = 1:iMax
    for j = 1:jMax;
        if entryRun(i) == run(j)
            check(i) = 1;
        end
    end
    if check(i) == 0
        k = k+1;
        failedRunData(k,:) = entryTimes(i,:);
    end
end

failedRunData(k+1:iMax,:) = [];
failedRun = failedRunData(:,2);
failedDataLog = failedRunData(:,3);

oldDir = cd('../../DataSets');
save('FailedRunData','failedRun','failedDataLog');
cd(oldDir);