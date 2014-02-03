function waitTime = calc_waiting_event_time(time)
%Calculates waiting time between two successive and successful events

time_order = sort(time);
iMax=numel(time_order);
waitTime=zeros(size(time));

for i = 2:iMax
    waitTime(i-1) = time_order(i) - time_order(i-1);
end