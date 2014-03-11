oldDir = cd('../../DataSets/');
load('ShiftStartToFirstAndLastRunTimeData.mat');
cd(oldDir);

timeToFirstRunTime = shiftStartToFirstRunTime*24; %hour
timeToLastRunTime = shiftStartToLastRunTime*24;

histFirst = figure;
x1 = 0.5:1:7.5;
hist(timeToFirstRunTime,x1);
xlim([0,8]);
title('time difference between the when shift starts and when the experiment starts running')
xlabel('time difference [hour]');
ylabel('counts');

histLast = figure;
x2 = 0.5:1:18;
hist(timeToLastRunTime,x2);
xlim([0,18]);
title('time difference between the when shift starts and when the experiment ends running')
xlabel('time difference [hour]');
ylabel('counts');

cd('HistShiftStartToFirstAndLastRunTime');
print(histFirst,'-dpdf','HistShiftStartToFirstRunTime.pdf');
print(histLast,'-dpdf','HistShiftStartToLastRunTime.pdf');
cd('../');
