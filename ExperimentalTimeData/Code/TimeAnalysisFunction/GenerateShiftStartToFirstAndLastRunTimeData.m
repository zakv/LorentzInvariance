%Calculate time from when shift starts to when the first run starts
%      and time from when shift starts to when the last run starts

oldDir = cd('../../DataSets');
load('GuessedShiftTimeData');% successfulShitTime
load('AttemptedStartingTimeCycleData');% AttemptedStartingTime
cd(oldDir);

firstRunTime = AttemptedTimeCycle(:,1);
lastRunTime = AttemptedTimeCycle(:,2);
startTime = successfulShiftTime(:,1);

iMax = numel(firstRunTime);
jMax = numel(startTime);
shiftStartToFirstRunTime = zeros(size(startTime));
shiftStartToLastRunTime = zeros(size(startTime));
k = 0;

for j = 1:jMax
    for i = 1:iMax
        if startTime(j) < firstRunTime(i)
            k = k+1;
            shiftStartToFirstRunTime(k) = firstRunTime(i) - startTime(j);
            shiftStartToLastRunTime(k) = lastRunTime(i) - startTime(j);
            break
        end
    end
end
shiftStartToFirstRunTime(k+1:jMax,:) = [];
shiftStartToLastRunTime(k+1:jMax,:) = [];

oldDir = cd('../../DataSets');
save('ShiftStartToFirstAndLastRunTimeData', 'shiftStartToFirstRunTime','shiftStartToLastRunTime');
cd(oldDir);

