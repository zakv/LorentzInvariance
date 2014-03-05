clear all;

oldDir = cd('../../../ExperimentalTimeData/DataSets');
shift_start_end_times_obj = load('GuessedShiftTimeData.mat');
cd(oldDir);
shift_start_end = shift_start_end_times_obj.successfulShiftTime;
count_first_last = calc_events_per_time_cycle(shift_start_end);
eventsPerShift = count_first_last(:,1);
firstEventTime = count_first_last(:,2);
lastEventTime = count_first_last(:,3);

oldDir = cd('../../../ExperimentalTimeData/DataSets');
save('EventsInShiftData.mat','eventsPerShift','firstEventTime','lastEventTime');
cd(oldDir);