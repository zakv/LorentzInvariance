clear all;

t = event_time();
runNumber = t.run('all','all',0);
SuccessfulRunStartingTime = get_starting_time(runNumber,'elog');

oldDir = cd('../../../ExperimentalTimeData/DataSets');
save('SuccessfulRunStartingTimeData.mat','SuccessfulRunStartingTime');
cd(oldDir);