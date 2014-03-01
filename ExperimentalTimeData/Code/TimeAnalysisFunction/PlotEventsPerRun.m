% Makes graphs which show number of events per runs.

clear all;
close all;

t = event_time();
run = t.run('all','all',0);
A = calc_events_per_run(run);
count = A(:,2);

%disp/graph
disp('Event/Run Count');
disp(calc_events_per_run(run));
X = strcat('  total -',num2str(length(run)),'events');
disp(X);

h = figure;
bar(count)
xlabel('Number of events per successful run')
ylabel('Count')
oldDir = cd('PlotEventsPerRun');
print(h,'-depsc','NumberEventsPerRun_all.eps')
print(h,'-dpdf','NumberEventsPerRun_all.pdf')
cd(oldDir);