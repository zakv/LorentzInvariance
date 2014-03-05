%Reads Guessed Shift Time which was typed by hand on Excel file.

oldDir = cd('../../DataSets/RawData/');
readFilename = 'ShiftGuess.xlsx';
readSheet = 1;
readxlRange = 'C2:C114';
shiftStTimeEx = xlsread(readFilename, readSheet, readxlRange);
shiftStTime = x2mdate(shiftStTimeEx);

readxlRange = 'D2:D114';
shiftEndTimeEx = xlsread(readFilename, readSheet, readxlRange);
shiftEndTime = x2mdate(shiftEndTimeEx);
cd(oldDir);

%Shift time only with successful events
oldDir = cd('../TimeAnalysisFunction/');
attemptedEventPerShift = calc_events_per_shift();
cd(oldDir);
successfulEventPerShift = attemptedEventPerShift(attemptedEventPerShift~=0);
shiftStTimeEx_ev = shiftStTimeEx(attemptedEventPerShift~=0);
shiftEndTimeEx_ev = shiftEndTimeEx(attemptedEventPerShift~=0);
shiftStTime_ev = shiftStTime(attemptedEventPerShift~=0);
shiftEndTime_ev = shiftEndTime(attemptedEventPerShift~=0);


attemptedShiftTime = [shiftStTime, shiftEndTime];
successfulShiftTime = [shiftStTime_ev, shiftEndTime_ev];

oldDir = cd('../../DataSets/');
save('GuessedShiftTimeData','attemptedShiftTime','attemptedEventPerShift',...
    'successfulShiftTime','successfulEventPerShift');
cd(oldDir);