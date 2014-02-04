
clear all;

oldDir = cd('../../DataSets');
load('AttemptedStartingTimeData');
cd(oldDir);

timeCycle = calc_time_cycle(AttemptedStartingTime);

oldDir = cd('../../DataSets');
save('AttemptedStartingTimeCycleData','timeCycle');
cd(oldDir);

eventPerCycle = calc_events_per_starting_time_cycle();

%iMax = numel(eventPerCycle);
%for i = 1:iMax
timeCycle = timeCycle(eventPerCycle~=0,:);
eventPerCycle = eventPerCycle(eventPerCycle~=0);

deadTime = calc_dead_time();

oldDir = cd('../../DataSets');
save('AttemptedStartingTimeCycleData','timeCycle','eventPerCycle','deadTime');
cd(oldDir);