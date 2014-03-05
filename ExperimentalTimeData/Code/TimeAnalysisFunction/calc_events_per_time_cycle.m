function [count_first_last] = calc_events_per_time_cycle(timeCycle)
%calculate successful events per shift cycle

startTime = timeCycle(:,1);
endTime = timeCycle(:,2);
t = event_time();
time = t.local('all','all',0);
run = t.run('all','all',0);

iMax = numel(time);
jMax = numel(startTime);
count = zeros(size(startTime));
shiftFound = zeros(iMax,1); 
firstEventTime = zeros(jMax,1);
lastEventTime = zeros(jMax,1);
count_first_last = zeros(jMax,3);
for j = 1:jMax
    count(j) = 0;
    for i = 1:iMax
        if startTime(j)-(1/48) <= time(i) && time(i) <= endTime(j) + (1/48) %+-30min
            count(j) = count(j) + 1;
            shiftFound(i) = true;
            if count(j) == 1
                firstEventTime(j) = time(i);
            end
            lastEventTime(j) = time(i);
        end
    end
    count_first_last(j,:) = [count(j),firstEventTime(j),lastEventTime(j)];
end

for i = 1:iMax
    if shiftFound(i) == false
            dispstr = [datestr(time(i)),' run=',num2str(run(i)),' is out of shift'];
            disp(dispstr);
    end
end
