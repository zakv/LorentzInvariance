function [count_first_last] = calc_events_per_time_cycle(time,timeCycle)
%calculate number of times within each time cycle, return number of the
%times, and first and last time in the time cycle

startTime = timeCycle(:,1);
endTime = timeCycle(:,2);

iMax = numel(time);
jMax = numel(startTime);
count = zeros(size(startTime));
shiftFound = zeros(iMax,1); 
firstEventTime = zeros(jMax,1);
lastEventTime = zeros(jMax,1);
count_first_last = zeros(jMax,3);
time = sort(time);
for j = 1:jMax
    count(j) = 0;
    for i = 1:iMax
        if startTime(j)-(2/24) <= time(i) && time(i) <= endTime(j) + (2/24) %-2hours, +2hours
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

%check times which are out of cycle
for i = 1:iMax
    if shiftFound(i) == false
            dispstr = ['event ',datestr(time(i)),' is out of shift'];
            disp(dispstr);
    end
end

