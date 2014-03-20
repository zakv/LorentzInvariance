function [time] = calc_total_time_of_cycles(timeCycle)
%calculates total times of all cycles.

startTime = timeCycle(:,1);
endTime = timeCycle(:,2);

timeSpan = endTime - startTime;

time = sum(timeSpan);
end

