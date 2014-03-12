%Generate cycle. output : first and last run's spillLog Entry time for each
%shift

t = event_time();
spillLogEntryLocal = t.spillLogEntryLocal();

timeCycle = calc_time_cycle(spillLogEntryLocal);

oldDr = cd('../../DataSets/');
save('AllRunSpillLogEntryTimeCycleData','timeCycle');
cd(oldDr);