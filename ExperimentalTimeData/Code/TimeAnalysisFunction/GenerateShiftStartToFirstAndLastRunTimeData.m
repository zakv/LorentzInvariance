%Calculate time from when shift starts to when the first run starts
%      and time from when shift starts to when the last run starts

oldDir = cd('../../DataSets');
shift_time_obj = load('GuessedShiftTimeData');% successfulShitTime
time_cycle_obj = load('AttemptedStartingTimeCycleData');% AttemptedStartingTime
cd(oldDir);

firstRunTime = time_cycle_obj.AttemptedStartingTimeCycle(:,1);
lastRunTime = time_cycle_obj.AttemptedStartingTimeCycle(:,2);

for m = 1:2
    if m==1
        shiftStartTime = shift_time_obj.successfulShiftTime(:,1);
    end
    if m==2
        shiftStartTime = shift_time_obj.attemptedShiftTime(:,1);
    end

    iMax = numel(firstRunTime);
    jMax = numel(shiftStartTime);
    shiftStartToFirstRunTime = zeros(size(shiftStartTime));
    shiftStartToLastRunTime = zeros(size(shiftStartTime));
    k = 0;

    for j = 1:jMax
        for i = 1:iMax
            if shiftStartTime(j) < firstRunTime(i)
                k = k+1;
                shiftStartToFirstRunTime(k) = firstRunTime(i) - shiftStartTime(j);
                shiftStartToLastRunTime(k) = lastRunTime(i) - shiftStartTime(j);
                break
            end
        end
    end
    shiftStartToFirstRunTime(k+1:jMax,:) = [];
    shiftStartToLastRunTime(k+1:jMax,:) = [];

    if m==1
        successfulShiftStartToFirstAttemptedRunTime = shiftStartToFirstRunTime;
        successfulShiftStartToLastAttemptedRunTime = shiftStartToLastRunTime;
    end
    if m==2
        attemptedShiftStartToFirstAttemptedRunTime = shiftStartToFirstRunTime;
        attemptedShiftStartToLastAttemptedRunTime = shiftStartToLastRunTime;
    end    
end

oldDir = cd('../../DataSets');
save('ShiftStartToFirstAndLastRunTimeData',...
    'successfulShiftStartToFirstAttemptedRunTime','successfulShiftStartToLastAttemptedRunTime',...
    'attemptedShiftStartToFirstAttemptedRunTime','attemptedShiftStartToLastAttemptedRunTime');
cd(oldDir);

