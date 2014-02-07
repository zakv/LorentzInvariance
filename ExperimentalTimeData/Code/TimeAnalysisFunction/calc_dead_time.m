function [deadTime] = calc_dead_time()

oldDir = cd('../../DataSets');
load('AttemptedStartingTimeCycleData');
cd(oldDir);

t = event_time();
eventTime = t.local('all','all',0);
eventTime = sort(eventTime);

startTime = timeCycle(:,1);

iMax = numel(eventTime);
jMax = numel(startTime);
deadTime = zeros(size(startTime));
k = 0;

for j = 1:jMax
    for i = 1:iMax
        if startTime(j) < eventTime(i)
            k = k+1;
            deadTime(k) = eventTime(i) - startTime(j);
            break
        end
    end
end
deadTime(k+1:jMax,:) = [];
