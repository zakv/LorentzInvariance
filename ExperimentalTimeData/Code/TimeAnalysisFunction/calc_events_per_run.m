function number = calc_events_per_run(run)
% Calculates the number of runs with same number of events per run.
%    Sorts run numbers
%    Counts the overlapped run number
%
%    output : [m count]
%             m - number of events per run
%             count - number of runs which has m events

run_sort = sort(run);

j = 1;
k = 1;
iMax = numel(run_sort);
EventsPerRuns = zeros(numel(run_sort),2);

for i = 2:iMax
    if run_sort(i) == run_sort(i-1)
        k = k+1;
    elseif run_sort(i) > run_sort(i-1);
        EventsPerRuns(j,:) = [run_sort(i-1) k];
        j = j+1;
        k = 1;
    else
        disp('ERROR : run numbers are not in order');
    end
    if i == iMax
            EventsPerRuns(j,:) = [run_sort(i) k];
    end
end

maxNumber = max(EventsPerRuns(:,2));
number = zeros(maxNumber,2);
for m = 1:maxNumber
    number(m,:) =[m length(EventsPerRuns(EventsPerRuns == m))];
end