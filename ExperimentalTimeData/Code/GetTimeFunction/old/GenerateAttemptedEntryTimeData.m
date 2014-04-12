%Generate attempted (only those written in the elog data nearby the run
%number) run's entry data. This gets inadequate data. If you want to get
%all attempted data, you should you Entry time data taken from spillLog
%files.
%
%   MEMO : Failed to find date for runNumber=21822,25888
%   entryTimes, entryTimes2010, entryTimes2011 are sorted

oldDir = cd('../../Datasets');
load('RunData');
cd(oldDir);

entryTimes2010R = get_attempted_entry_time(run2010R);
entryTimes2010L = get_attempted_entry_time(run2010L);
entryTimes2011R = get_attempted_entry_time(run2011);

entry21822 = get_entry_time(21822);
entryTimes21822 = [entry21822, 21822, 20173, 41]; %2010L
entry25888 = get_entry_time(25888);
entryTimes25888 = [entry25888, 25888, 26348, 85]; %2011R

entryTimes2010L = vertcat(entryTimes2010L,entryTimes21822);
entryTimes2011R = vertcat(entryTimes2011R,entryTimes25888);

entryTimes2010 = unique(vertcat(entryTimes2010L,entryTimes2010R),'rows');
entryTimes2011 = unique(entryTimes2011R,'rows');
entryTimes = vertcat(entryTimes2010,entryTimes2011);

AttemptedRun = entryTimes(:,2);
AttemptedDataLog = entryTimes(:,3);

oldDir = cd('../../Datasets');
save('AttemptedRunData','AttemptedRun','AttemptedDataLog');
save('AttemptedEntryTimeData','entryTimes2010R','entryTimes2010L','entryTimes2011R',...
    'entryTimes2010','entryTimes2011','entryTimes');
cd(oldDir);