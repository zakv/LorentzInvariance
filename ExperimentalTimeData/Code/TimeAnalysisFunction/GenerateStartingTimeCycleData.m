clear all;

oldDir = cd('../../DataSets');
load('AttemptedStartingTimeData');
cd(oldDir);

AttemptedStartingTimeCycle = calc_time_cycle(AttemptedStartingTime);
AttemptedEventPerCycle = calc_events_per_time_cycle(AttemptedStartingTimeCycle);

oldDir = cd('../../DataSets');
save('AttemptedStartingTimeCycleData','AttemptedStartingTimeCycle','AttemptedEventPerCycle');
cd(oldDir);

SuccessfulStartingTimeCycle = AttemptedStartingTimeCycle(AttemptedEventPerCycle~=0,:);
SuccessfulEventPerCycle = calc_events_per_time_cycle(SuccessfulStartingTimeCycle);
deadTime = calc_dead_time(SuccessfulStartingTimeCycle);

oldDir = cd('../../DataSets');
save('SuccessfulStartingTimeCycleData','SuccessfulStartingTimeCycle','SuccessfulEventPerCycle','deadTime');
cd(oldDir);