function [count] = calc_events_per_shift()
%calculate number of successful events per shift cycle
%Should use calc_events_per_time_cycle.m instead of this function 

oldDir = cd('../../DataSets');
time_cycle_obj=load('AttemptedStartingTimeCycleData');
cd(oldDir);
startTime = time_cycle_obj.AttemptedStartingTimeCycle(:,1);
endTime = time_cycle_obj.AttemptedStartingTimeCycle(:,2);
t = event_time();
time = t.local('all','all',0);
run = t.run('all','all',0);

iMax = numel(time);
jMax = numel(startTime);
count = zeros(size(startTime));
shiftFound = zeros(iMax,1);

for j = 1:jMax
    count(j) = 0;
    for i = 1:iMax
        if startTime(j)-(1/48) <= time(i) && time(i) <= endTime(j) + (1/48) %+-30min
            count(j) = count(j) + 1;
            shiftFound(i) = true;
        end
    end
end

for i = 1:iMax
    if shiftFound(i) == false
            dispstr = [datestr(time(i)),' run=',num2str(run(i)),' is out of shift'];
            disp(dispstr);
    end
end
