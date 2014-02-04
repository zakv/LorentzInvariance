%generate time Cycle Data

oldDr = cd('../../DataSets/');
load('AttemptedEntryTimeData');
cd(oldDr);

time = entryTimes(:,1);
timeCycle = calc_time_cycle(time);

oldDr = cd('../../DataSets/');
save('AttemptedEntryTimeCycleData','timeCycle');
cd(oldDr);
