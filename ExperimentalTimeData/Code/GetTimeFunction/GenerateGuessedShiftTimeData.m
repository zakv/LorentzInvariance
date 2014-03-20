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

shiftCycle = [shiftStTime, shiftEndTime];

%Shift time which had more than one runs with e+ catch
t = event_time();
attemptedRunEntryTime = t.attemptedSpillLogEntryTime();
oldDir = cd('../TimeAnalysisFunction/');
attemptedRunsPerShift = calc_events_per_time_cycle(attemptedRunEntryTime,shiftCycle);
cd(oldDir);
shiftCycle = shiftCycle(attemptedRunsPerShift(:,1)>=2,:);%Should it be from 1 or 2?

oldDir = cd('../../DataSets/');
save('GuessedAttemptedShiftTimeData','shiftCycle');
cd(oldDir);