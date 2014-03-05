function [timeDiff] = calc_firstShiftTime_to_lastEventTime()

oldDir = cd('../../DataSets');
load('AttemptedStartingTimeData')
shift_time_obj = load('GuessedShiftTimeData.mat');
cd(oldDir);

shift_cycle = shift_time_obj.successfulShiftTime;
shift_start_time = shift_cycle(:,1);
eventN_first_last = calc_events_per_time_cycle(shift_cycle);
last_event_time = eventN_first_last(:,3);
timeDiff = last_event_time - shift_start_time;

end