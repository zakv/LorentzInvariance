% generate SpillLog entry time

clear all;

%get Entry Data from spilllLog summary page
[spillLogEntryTime_raw,run_raw,dataLog_raw] = get_spillLogPage_entry_time();

iMax = numel(spillLogEntryTime_raw);
spillLogEntryTime = zeros(iMax,1);
run = zeros(iMax,1);
dataLog = zeros(iMax,1);
j = 0;

%use only data from 0ct 7th,2010 to Nov 16th 2011 (run 21218~29359),
%exclude data with same entry time
for i = 1:iMax
    if run_raw(i) >= 21218 && run_raw(i) <=29359
        if i == 1 || (i>=2 && spillLogEntryTime_raw(i) - spillLogEntryTime_raw(i-1) > 0)
            j = j+1;
            spillLogEntryTime(j) = spillLogEntryTime_raw(i);
            run(j) = run_raw(i);
            dataLog(j) = dataLog_raw(i);
        end
    end
end

spillLogEntryTime(j+1:iMax,:) = [];
run(j+1:iMax,:) = [];
dataLog(j+1:iMax,:) = [];

oldDir = cd('../../Datasets');
save('spillLogEntryTimeData','spillLogEntryTime','run','dataLog');
cd(oldDir);

