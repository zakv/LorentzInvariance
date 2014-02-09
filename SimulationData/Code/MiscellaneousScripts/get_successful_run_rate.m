run_times=load('Data/AttemptedStartingTimeCycleData.mat');
n_events=load('Data/SuccessfulEventPerRunData.mat');
n_events=n_events.eventsPerRun;
n_successful_runs=sum(n_events(:,2));
starts=run_times.timeCycle(:,1);
ends=run_times.timeCycle(:,2);
total_run_time=sum(ends-starts);
fprintf('Total run time: %f days\n',total_run_time);
events_per_cycle=run_times.eventPerCycle;
total_events=sum(events_per_cycle);
fprintf('Number of Hbars: %d\n',total_events);
fprintf('Number of successful runs: %d\n',n_successful_runs);
time_lambda=n_successful_runs/total_run_time;
fprintf('time_lambda is %f  events/day\n',time_lambda);