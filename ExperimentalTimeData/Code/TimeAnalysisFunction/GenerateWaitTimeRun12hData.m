clear all;
close all;

t = event_time();
utc = t.utc('all','all',0);
waitTime_run = calc_waiting_run_time(utc);

%graph : 0 < waiting time < 12h
waitTime = waitTime_run( waitTime_run <= 12/24);

oldDir = cd('../../DataSets');
save('WaitTimeRun12hData','waitTime');
cd(oldDir);