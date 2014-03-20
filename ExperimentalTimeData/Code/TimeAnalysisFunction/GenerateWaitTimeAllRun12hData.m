%calculate the time between two successive runs which time was taken from
%spillLog entry time
clear all;
close all;

t = event_time();
entryLocal = t.spillLogEntryLocal();
waitTime_allRun = calc_waiting_run_time(entryLocal);

%graph : 0 < waiting time < 12h
waitTime_allRun = waitTime_allRun( waitTime_allRun <= 12/24);

oldDir = cd('../../DataSets');
save('WaitTimeAllRun12hData','waitTime_allRun');
cd(oldDir);