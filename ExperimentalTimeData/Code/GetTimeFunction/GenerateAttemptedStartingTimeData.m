clear all;

oldDir = cd('../../DataSets');
load('FailedRunData');
load('RunData');
cd(oldDir);

%failedDataLog
FailedStartingTime = get_starting_time(run,'elog');
SuccessfulStartingTime = get_starting_time(failedDataLog,'DataLog');

AttemptedStartingTime = vertcat(FailedStartingTime,SuccessfulStartingTime);
AttemptedStartingTime = AttemptedStartingTime(~isnan(AttemptedStartingTime));
AttemptedStartingTime = sort(AttemptedStartingTime);

oldDir = cd('../../DataSets');
save('AttemptedStartingTimeData','AttemptedStartingTime');
cd(oldDir);
