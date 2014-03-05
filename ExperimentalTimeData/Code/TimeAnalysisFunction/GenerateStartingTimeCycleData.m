clear all;

oldDir = cd('../../DataSets');
load('AttemptedStartingTimeData');
cd(oldDir);

AttemptedStartingTimeCycle = calc_time_cycle(AttemptedStartingTime);
AttemptedEventN_start_end = calc_events_per_time_cycle(AttemptedStartingTimeCycle);
AttemptedEventPerCycle = AttemptedEventN_start_end(:,1);
AttemptedStartingTimeToFirstEvent = calc_dead_time(AttemptedStartingTimeCycle);

SuccessfulStartingTimeCycle = AttemptedStartingTimeCycle(AttemptedEventPerCycle~=0,:);
SuccessfulEventN_start_end = calc_events_per_time_cycle(SuccessfulStartingTimeCycle);
SuccessfulEventPerCycle = SuccessfulEventN_start_end(:,1);
SuccessfulStartingTimeToFirstEvent = calc_dead_time(SuccessfulStartingTimeCycle);

oldDir = cd('../../DataSets');
save('AttemptedStartingTimeCycleData','AttemptedStartingTimeCycle','AttemptedEventPerCycle',...
    'AttemptedStartingTimeToFirstEvent');
save('SuccessfulStartingTimeCycleData','SuccessfulStartingTimeCycle','SuccessfulEventPerCycle',...
    'SuccessfulStartingTimeToFirstEvent');
cd(oldDir);