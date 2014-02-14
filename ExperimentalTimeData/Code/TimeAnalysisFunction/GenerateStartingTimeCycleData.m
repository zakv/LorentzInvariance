clear all;

oldDir = cd('../../DataSets');
load('AttemptedStartingTimeData');
cd(oldDir);

AttemptedTimeCycle = calc_time_cycle(AttemptedStartingTime);
AttemptedEventPerCycle = calc_events_per_time_cycle(AttemptedTimeCycle);

oldDir = cd('../../DataSets');
save('AttemptedStartingTimeCycleData','AttemptedTimeCycle','AttemptedEventPerCycle');
cd(oldDir);

SuccessfulTimeCycle = AttemptedTimeCycle(AttemptedEventPerCycle~=0,:);
SuccessfulEventPerCycle = calc_events_per_time_cycle(SuccessfulTimeCycle);
deadTime = calc_dead_time(SuccessfulTimeCycle);

oldDir = cd('../../DataSets');
save('SuccessfulStartingTimeCycleData','SuccessfulTimeCycle','SuccessfulEventPerCycle','deadTime');
cd(oldDir);