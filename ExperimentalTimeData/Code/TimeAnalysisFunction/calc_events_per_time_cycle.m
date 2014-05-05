function [count,timeCycle] = calc_events_per_time_cycle(time,fixedCycle)
%calculate number of times within each fixed cycle, return number of the
%times, and first and last time in the time cycle.

%preallocate
iMax = numel(time);
jMax = numel(fixedCycle(:,1));
count = zeros(jMax,1);
shiftFound = zeros(iMax,1); 
timeCycle = zeros(jMax,2);

%in case time is not in order
time = sort(time);

for j = 1:jMax
    count(j) = 0;
    for i = 1:iMax
        if fixedCycle(j,1)-(2/24) <= time(i) && time(i) <= fixedCycle(j,2) + (2/24) %-2hours, +2hours
            count(j) = count(j) + 1;
            shiftFound(i) = true;
            if count(j) == 1
                timeCycle(j,1) = time(i);
            end
            timeCycle(j,2) = time(i);
        end
    end
    %if there is no time in the fixedCycle
    if count(j) == 0
        timeCycle(j,:) = [NaN, NaN];
    end
end

%check times which are out of cycle
for i = 1:iMax
    if shiftFound(i) == false && ~isnan(time(i))
            dispstr = ['event ',datestr(time(i)),' is out of shift'];
            disp(dispstr);
    end
end

