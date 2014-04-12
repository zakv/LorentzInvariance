%GenerateEntryTimeWithEplusCatchData
%I deleted this code accidentially... need to rewrite again some time...

t = event_time();
dataLogNumber = t.spillLogDataLog();
Ind1 = find(dataLogNumber==(9504));
Ind2 = find(dataLogNumber <=9555 & 9553 <= dataLogNumber );
Ind3 = find(dataLogNumber <=17672 & 17670 <= dataLogNumber );
Ind = vertcat(Ind1,Ind2,Ind3);
dataLogNumber(Ind,:) = [];

%exclude test runs
%run 21567 ( log 9504 ), 16-oct-2010
%run 21609~21611   ( log 9553,9554,9555 ), 17-oct-2010
%run 29358,29359   ( log 17670, 17672   ) (out of shift), 16-Nov-2011

%remove two test runs with e+ catch
%run 24850(dataLog 12957) EntryTime 8.20.2011 7:57, run 24339(no datalog) Entrytime 2011.8.7 00:58 

%add two runs missing
%run 28204 (dataLog 16487), run 26890(datalog 15064)

time_run_dataLog = get_spillLog_entry_time_with_epluscatch(dataLogNumber);
run = time_run_dataLog(:,1);
spillLogEntryTime = time_run_dataLog(:,2);
dataLog = time_run_dataLog(:,3);



oldDir = cd('../../DataSets/');
save('EntryTimeWithEplusCatchData.mat','run','spillLogEntryTime','dataLog');
cd(oldDir);