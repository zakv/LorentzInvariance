
clear all;
close all;

t = event_time();
run = t.run('all','all',0);
eventsPerRun = calc_events_per_run(run);

oldDir = cd('../../DataSets');
save('SuccessfulEventPerRunData','eventsPerRun');
cd(oldDir);