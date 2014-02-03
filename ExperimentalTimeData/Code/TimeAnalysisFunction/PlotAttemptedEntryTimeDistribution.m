%Search shift time from local entery times we have

clear all;

oldDir = cd('../../DataSets/');
load('AttemptedEntryTimeData');
cd(oldDir);
time = entryTimes(:,1);

xlabelstr = 'Date';
ylabelstr = 'Local Time';

%boundary
min2010 = datenum(2010,1,1);
max2010 = datenum(2011,1,1);
time2010 = time( min2010 < time & time < max2010 );

min2011 = datenum(2011,1,1);
max2011 = datenum(2012,1,1);
time2011 = time( min2011 < time & time < max2011 );

min2011_1 = max2010;
max2011_1 = datenum(2011,6,27);
time2011_1 = time( min2011_1 < time & time < max2011_1 );

min2011_2 = max2011_1;
max2011_2 = datenum(2011,8,29);
time2011_2 = time( min2011_2 < time & time < max2011_2 );

min2011_3 = max2011_2;
max2011_3 = datenum(2011,10,17);
time2011_3 = time( min2011_3 < time & time < max2011_3 );

min2011_4 = max2011_3;
max2011_4 = datenum(2012,1,1);
time2011_4 = time( min2011_4 < time & time < max2011_4 );

%plot
f2010 = figure;
plot_time(time2010);
set_for_shift_time_graph(time2010);
xlabel(xlabelstr)
ylabel(ylabelstr)

f2011 = figure;
plot_time(time2011);
set_for_shift_time_graph(time2011);
xlabel(xlabelstr)
ylabel(ylabelstr)

f2011_1 = figure;
plot_time(time2011_1);
set_for_shift_time_graph(time2011_1);
xlabel(xlabelstr)
ylabel(ylabelstr)

f2011_2 = figure;
plot_time(time2011_2);
set_for_shift_time_graph(time2011_2);
xlabel(xlabelstr)
ylabel(ylabelstr)

f2011_3 = figure;
plot_time(time2011_3);
set_for_shift_time_graph(time2011_3);
xlabel(xlabelstr)
ylabel(ylabelstr)

f2011_4 = figure;
plot_time(time2011_4);
set_for_shift_time_graph(time2011_4);
xlabel(xlabelstr)
ylabel(ylabelstr)

%print
cd('PlotEntryTimeDistribution')
print(f2010,'-depsc','PlotTime2010.eps')
print(f2011,'-depsc','PlotTime2011.eps')
print(f2011_1,'-depsc','PlotTime2011_1.eps')
print(f2011_2,'-depsc','PlotTime2011_2.eps')
print(f2011_3,'-depsc','PlotTime2011_3.eps')
print(f2011_4,'-depsc','PlotTime2011_4.eps')
cd('../')



