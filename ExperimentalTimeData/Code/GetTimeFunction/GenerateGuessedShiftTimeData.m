%Reads Guessed Shift Time which was typed by hand on Excel file.

oldDir = cd('../../DataSets/RawData/');
readFilename = 'ShiftGuess.xlsx';
readSheet = 1;
readxlRange = 'A2:A171';
shiftStTimeEx = xlsread(readFilename, readSheet, readxlRange);
shiftStTime = x2mdate(shiftStTimeEx);

readxlRange = 'B2:B171';
shiftEndTimeEx = xlsread(readFilename, readSheet, readxlRange);
shiftEndTime = x2mdate(shiftEndTimeEx);
cd(oldDir);

shiftCycle_all = [shiftStTime, shiftEndTime];

%Shift time which had more than one runs with e+ catch
t = event_time();
attemptedRunEntryTime = t.attemptedSpillLogEntryTime();
eventTime = t.local('all','all',0);

oldDir = cd('../TimeAnalysisFunction/');
attemptedRunsPerShift = calc_events_per_time_cycle(attemptedRunEntryTime,shiftCycle_all);
shiftCycle = shiftCycle_all(attemptedRunsPerShift(:,1)>=1,:);
%Should be >=1 run, otherwise this excludes the shift which has only one
%run which is successful.
count_first_last = calc_events_per_time_cycle(eventTime,shiftCycle_all);
n_eventsPerShift = count_first_last(:,1);
successfulShiftCycle = shiftCycle_all(n_eventsPerShift>0,:);
cd(oldDir);

oldDir = cd('../../DataSets/');
save('GuessedAttemptedShiftTimeData','shiftCycle');
save('GuessedSuccessfulShiftTimeData','successfulShiftCycle');
cd(oldDir);