function waitTime = calc_waiting_run_time(time)
%Calculates waiting time between two successful runs
%   Calculates the time difference between two successive events
%   Excludes waiting time if it is ~0, (Excludes the waiting event time at same run)

time_order = sort(time);
iMax=numel(time_order);
waitTime_event=zeros(size(time));

for i = 2:iMax
    waitTime_event(i-1) = time_order(i) - time_order(i-1);
end
waitTime = waitTime_event(waitTime_event ~= 0);