%Generate cycle. output : first and last run's spillLog Entry time for each
%shift

t = event_time();
spillLogEntryTime = t.spillLogEntryTime();

timeCycle = calc_time_cycle(spillLogEntryTime);

oldDr = cd('../../DataSets/');
save('AllRunSpillLogEntryTimeCycleData','timeCycle');
cd(oldDr);