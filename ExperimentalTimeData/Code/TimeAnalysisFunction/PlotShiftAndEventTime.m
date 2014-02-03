%Plots Guessed Shift time and successiful events distribution

%Plot Shift and Event time

clear all;

oldDir = cd('../../DataSets/');
load('GuessedShiftTimeData');
cd(oldDir);

t = event_time();
time = t.local('all','all',0);
time = sort(time);
time = time(:,1);
startTime = successfulShiftTime(:,1);
endTime = successfulShiftTime(:,2);

xlabelstr = 'Date';
ylabelstr = 'Local Time';

%boundary
min2010 = datenum(2010,1,1);
max2010 = datenum(2011,1,1);
time2010 = time( min2010 < time & time < max2010 );
startTime2010 = startTime( min2010 < startTime & startTime < max2010 );
endTime2010 = endTime( min2010 < endTime & endTime < max2010 );

min2011_1 = max2010;
max2011_1 = datenum(2011,6,27);
time2011_1 = time( min2011_1 < time & time < max2011_1 );
startTime2011_1 = startTime( min2011_1 < startTime & startTime < max2011_1 );
endTime2011_1 = endTime( min2011_1 < endTime & endTime < max2011_1 );

min2011_2 = max2011_1;
max2011_2 = datenum(2011,8,29);
time2011_2 = time( min2011_2 < time & time < max2011_2 );
startTime2011_2 = startTime( min2011_2 < startTime & startTime < max2011_2 );
endTime2011_2 = endTime( min2011_2 < endTime & endTime < max2011_2 );

min2011_3 = max2011_2;
max2011_3 = datenum(2011,10,17);
time2011_3 = time( min2011_3 < time & time < max2011_3 );
startTime2011_3 = startTime( min2011_3 < startTime & startTime < max2011_3 );
endTime2011_3 = endTime( min2011_3 < endTime & endTime < max2011_3 );

min2011_4 = max2011_3;
max2011_4 = datenum(2012,1,1);
time2011_4 = time( min2011_4 < time & time < max2011_4 );
startTime2011_4 = startTime( min2011_4 < startTime & startTime < max2011_4 );
endTime2011_4 = endTime( min2011_4 < endTime & endTime < max2011_4 );

%plot
f2010 = figure;
set_for_shift_time_graph(time2010);
patch_time_cycle(startTime2010,endTime2010);
hold on;
plot_time(time2010);
xlabel(xlabelstr)
ylabel(ylabelstr)

f2011_1 = figure;
set_for_shift_time_graph(time2011_1);
patch_time_cycle(startTime2011_1,endTime2011_1);
hold on;
plot_time(time2011_1);
xlabel(xlabelstr)
ylabel(ylabelstr)

f2011_2 = figure;
set_for_shift_time_graph(time2011_2);
patch_time_cycle(startTime2011_2,endTime2011_2);
hold on;
plot_time(time2011_2);
xlabel(xlabelstr)
ylabel(ylabelstr)

f2011_3 = figure;
set_for_shift_time_graph(time2011_3);
patch_time_cycle(startTime2011_3,endTime2011_3);
hold on;
plot_time(time2011_3);
xlabel(xlabelstr)
ylabel(ylabelstr)

f2011_4 = figure;
set_for_shift_time_graph(time2011_4);
patch_time_cycle(startTime2011_4,endTime2011_4);
hold on;
plot_time(time2011_4);
xlabel(xlabelstr)
ylabel(ylabelstr)

cd('PlotShiftAndEventTime')
print(f2010,'-depsc','PlotTime2010.eps')
print(f2011_1,'-depsc','PlotTime2011_1.eps')
print(f2011_2,'-depsc','PlotTime2011_2.eps')
print(f2011_3,'-depsc','PlotTime2011_3.eps')
print(f2011_4,'-depsc','PlotTime2011_4.eps')
cd('../')



