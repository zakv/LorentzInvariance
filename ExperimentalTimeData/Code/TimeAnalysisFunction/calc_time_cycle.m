function [timeCycle] = calc_time_cycle(time)
%calculate the time cycle. One cycle is less than timeBoundary.

timeBoundary = 10/24; % 10hours

%%%%%%%%%%%%
iMax = numel(time);
j=1;

stTime = zeros(size(time));
endTime = zeros(size(time));

for i = 1:iMax
    if i == 1
        stTime(j) = time(i);
    elseif time(i)- time(i-1) > timeBoundary %10hours
        j=j+1;
        endTime(j-1) = time(i-1);
        stTime(j) = time(i);
    end
    if i == iMax
        endTime(j) = time(i);
    end
end

stTime(j+1:iMax,:)=[];
endTime(j+1:iMax,:)=[];

timeCycle = [stTime, endTime];

