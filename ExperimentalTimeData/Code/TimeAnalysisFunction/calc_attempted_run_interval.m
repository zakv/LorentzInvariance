function [AttemptedRunInterval] = calc_attempted_run_interval()
%calculate the interval of starting time of attempted Run
oldDir = cd('../../DataSets');
starting_time_obj = load('AttemptedStartingTimeData');
cd(oldDir);

AttemptedStartingTime = starting_time_obj.AttemptedStartingTime;
AttemptedRunInterval = calc_waiting_run_time(AttemptedStartingTime);
AttemptedRunInterval = AttemptedRunInterval( AttemptedRunInterval <= 12/24);%only smaller than 12hours
end