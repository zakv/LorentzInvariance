%Creates graphs of waiting time between two successful runs

clear all;
close all;

t = event_time();
utc = t.utc('all','all',0);
waitTime_run = calc_waiting_run_time(utc);

%graph : 0 < waiting time < 12h
waitTime_run_12h = waitTime_run( waitTime_run <= 12/24);

M_12h = mean(waitTime_run_12h);
std_12h = std(waitTime_run_12h);
X = ['mean_12h     = ', num2str(M_12h*24),'hour'];
disp(X);
X = ['std_12h     = ', num2str(std_12h*24),'hour'];
disp(X);

hz = figure;
x=1/8/24:1/4/24:(12-1/8)/24;
hist(waitTime_run_12h,x)
%[nelements,xcenters] = hist(waitTime_run_12h,x);
xlim([0,12/24])
title('Waiting time between successful runs')
xlabel('Waiting time [hour]')
ylabel('Number of events')
tcksX = {'0','1','2','3','4','5','6','7','8','9','10','11','12'};
set(gca,'XTick',0:1/24:12/24)
set(gca,'XTickLabel',tcksX)

cd('PlotWaitingRunTime')
print(hz,'-depsc','histWaitingRunTime_12h_allV2.eps')
print(hz,'-dpdf','histWaitingRunTime_12h_allV2.pdf')
cd('../')
