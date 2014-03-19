%GenerateEntryTimeWithEplusCatchData
%I deleted this code accidentially... need to rewrite again some time...

t = event_time();
dataLogNumber = t.??();all entry time

time_run_dataLog = get_spillLog_entry_time_with_epluscatch(dataLogNumber);
run_raw = time_run_dataLog(:,1);
spillLogEntryTime_raw = time_run_dataLog(:,2);
dataLog_raw = time_run_dataLog(:,3);
%decide the date for using

%remove two test runs with e+ catch
%run 24850(dataLog 12957) EntryTime 8.20.2011 7:57, run 24339(no datalog) Entrytime 2011.8.7 00:58 

%add two runs missing?
%run 28204 (dataLog 16487), run 26890(datalog 15064)

oldDir = cd('../../DataSets/');
save('EntryTimeWithEplusCatchData_raw.mat','run_raw','spillLogEntryTime_raw','dataLog_raw');
cd(oldDir);