%read Excel Time Array
%convert Excel time to MATLAB time

oldDir = cd('../ExcelFile/');
readFilename = '2010 QWP L 145events_resultv3.xlsx';
readSheet = 1;
readxlRange = 'E2:E146';
st2010L_matt_ex = xlsread(readFilename, readSheet, readxlRange);
st2010L_matt = x2mdate(st2010L_matt_ex);

readFilename = '2010 QWP R 27 events_resultv3.xlsx';
readSheet = 1;
readxlRange = 'E2:E28';
st2010R_matt_ex = xlsread(readFilename, readSheet, readxlRange);
st2010R_matt = x2mdate(st2010R_matt_ex);
cd(oldDir);

st2010_matt = vertcat(st2010L_matt,st2010R_matt);
st2010_matt = sort(st2010_matt);

%save data
save('EventTimeData_2010_matt','st2010L_matt','st2010R_matt','st2010_matt');
