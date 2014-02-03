% Makes Time Series Graphs of events (histogram and CDF for each case).
%   Gets data from eventTime20**.dat files
%   Makes histogram and CDF graph
%   Saves graphs with eps files
%
%NOTE - events with accurate time
% 2010 Left - 74/145 events
% 2010 Right - 25/27 events
% 2011 (Right) - 213/214 events
%      total 312/386 events


clear all;
close all;

t = event_time();

jd2011R = t.utc_jd('2011','R',0);
jd2010L = t.utc_jd('2010','L',0);
jd2010R = t.utc_jd('2010','R',0);

jd2011R_a = t.utc_jd('2011','R',1);
jd2010L_a = t.utc_jd('2010','L',1);
jd2010R_a = t.utc_jd('2010','R',1);

utc2011R_vec = datevec(t.utc('2011','R',0));
utc2010L_vec = datevec(t.utc('2010','L',0));
utc2010R_vec = datevec(t.utc('2010','R',0));

utc2y = t.utc('all','all',0);
type2y = t.type('all','all',0);
utc2y_vec = datevec(utc2y);

utc2y_a = t.utc('all','all',1);
utc2y_a_vec = datevec(utc2y_a);

utcR = t.utc('all','R',0);
utcR_vec = datevec(utcR);

utcR_a = t.utc('all','R',1);
utcR_a_vec = datevec(utcR_a);

utcL = t.utc('all','L',0);
utcL_vec = datevec(utcL);

utcL_a = t.utc('all','L',1);
utcL_a_vec = datevec(utcL_a);


%2011 (2011R)
jd2011 = jd2011R;
h2011R = figure;
xmin = juliandate(2011,1,1);
xmax = juliandate(2012,1,1);
binwidth = 7;
x=xmin:binwidth:xmax;
hist(jd2011R,x)
xlim([xmin,xmax]);
tickwidth = (xmax - xmin);
set(gca,'XTick',xmin:tickwidth:xmax)
set(gca,'XTickLabel',{'2011/1/1','2012/1/1'})
title('2011 (right)')
xlabel('UTC')
ylabel('number of events')

c2011R = figure;
cdfplot(jd2011R)
xmin = juliandate(2011,1,1);
xmax = juliandate(2012,1,1);
xlim([xmin,xmax]);
tickwidth = (xmax - xmin);
set(gca,'XTick',xmin:tickwidth:xmax)
set(gca,'XTickLabel',{'2011/1/1','2012/1/1'})
title('CDF - 2011 (right)')
xlabel('UTC')


%2010R
h2010R = figure;
xmin = juliandate(2010,1,1);
xmax = juliandate(2011,1,1);
binwidth = 7;
x=xmin:binwidth:xmax;
hist(jd2010R,x)
xlim([xmin,xmax]);
tickwidth = (xmax - xmin);
set(gca,'XTick',xmin:tickwidth:xmax)
set(gca,'XTickLabel',{'2010/1/1','2011/1/1'})
title('2010 right')
xlabel('UTC')
ylabel('number of events')

c2010R = figure;
cdfplot(jd2010R)
xmin = juliandate(2010,1,1);
xmax = juliandate(2011,1,1);
xlim([xmin,xmax]);
tickwidth = (xmax - xmin);
set(gca,'XTick',xmin:tickwidth:xmax)
set(gca,'XTickLabel',{'2010/1/1','2011/1/1'})
title('CDF - 2010 right')
xlabel('UTC')


%2010L
h2010L = figure;
xmin = juliandate(2010,1,1);
xmax = juliandate(2011,1,1);
binwidth = 7;
x=xmin:binwidth:xmax;
hist(jd2010L,x)
xlim([xmin,xmax]);
tickwidth = (xmax - xmin);
set(gca,'XTick',xmin:tickwidth:xmax)
set(gca,'XTickLabel',{'2010/1/1','2011/1/1'})
title('2010 left')
xlabel('UTC')
ylabel('number of events')

c2010L = figure;
cdfplot(jd2010L)
xmin = juliandate(2010,1,1);
xmax = juliandate(2011,1,1);
xlim([xmin,xmax]);
tickwidth = (xmax - xmin);
set(gca,'XTick',xmin:tickwidth:xmax)
set(gca,'XTickLabel',{'2010/1/1','2011/1/1'})
title('CDF - 2010 left')
xlabel('UTC')


%2010
jd2010 = t.utc_jd('2010','all',0);
h2010 = figure;
xmin = juliandate(2010,1,1);
xmax = juliandate(2011,1,1);
binwidth = 7;
x=xmin:binwidth:xmax;
hist(jd2010,x)
xlim([xmin,xmax]);
tickwidth = (xmax - xmin);
set(gca,'XTick',xmin:tickwidth:xmax)
title('2010 (right&left)')
xlabel('UTC')
ylabel('number of events')
set(gca,'XTickLabel',{'2010/1/1','2011/1/1'})

c2010 = figure;
cdfplot(jd2010)
xmin = juliandate(2010,1,1);
xmax = juliandate(2011,1,1);
xlim([xmin,xmax]);
tickwidth = (xmax - xmin);
set(gca,'XTick',xmin:tickwidth:xmax)
set(gca,'XTickLabel',{'2010/1/1','2011/1/1'})
title('CDF - 2010 (right&left)')
xlabel('UTC')


%Yearly
jd2010trans = jd2010 +365;
jdYearly = vertcat(jd2010trans,jd2011);
hyear = figure;
xmin = juliandate(2011,1,1);
xmax = juliandate(2012,1,1);
binwidth = 7;
x=xmin:binwidth:xmax;
hist(jdYearly,x)
xlim([xmin,xmax]);
tickwidth = (xmax - xmin);
set(gca,'XTick',xmin:tickwidth:xmax)
title('Yearly (right&left)')
xlabel('UTC')
ylabel('number of events')
set(gca,'XTickLabel',{'01-Jan','01-Jan'})


%Yearly-new
%{
utc2010trans = t.utc('2010','all',0)+365;
utcYearly = vertcat(utc2010trans,t.utc('2011','all',0));
hyear = figure;
xmin = datenum(2011,1,1);
xmax = datenum(2012,1,1);
binwidth = 7;
x=xmin:binwidth:xmax;
hist(utcYearly,x)
xlim([xmin,xmax]);
%tickwidth = (xmax - xmin);
%set(gca,'XTick',xmin:tickwidth:xmax)
xlabel('UTC')
ylabel('number of events')
datetick('x','mmmyyyy','keeplimits')
%}

cyear = figure;
cdfplot(jdYearly)
xmin = juliandate(2011,1,1);
xmax = juliandate(2012,1,1);
xlim([xmin,xmax]);
tickwidth = (xmax - xmin);
set(gca,'XTick',xmin:tickwidth:xmax)
set(gca,'XTickLabel',{'1/1','1/1'})
title('CDF - Yearly (right&left)')
xlabel('UTC')

%two year span
jd2y = t.utc_jd('all','all',0);
h2y = figure;
xmin = juliandate(2010,1,1);
xmax = juliandate(2012,1,1);
binwidth = 7;
x=xmin:binwidth:xmax;
hist(jd2y,x)
xlim([xmin,xmax]);
tickwidth = (xmax - xmin)/2;
set(gca,'XTick',xmin:tickwidth:xmax)
title('Two Year span (right&left)')
xlabel('UTC')
ylabel('number of events')
set(gca,'XTickLabel',{'2010/1/1','2011/1/1','2012/1/1'})

c2y = figure;
cdfplot(jd2y)
xmin = juliandate(2010,1,1);
xmax = juliandate(2012,1,1);
xlim([xmin,xmax]);
tickwidth = (xmax - xmin)/2;
set(gca,'XTick',xmin:tickwidth:xmax)
set(gca,'XTickLabel',{'2010/1/1','2011/1/1','2012/1/1'})
title('CDF - Two Year span (right&left)')
xlabel('UTC')

%Yearly - right
jd2010Rtrans = jd2010R +365;
jdYearlyR = vertcat(jd2010Rtrans,jd2011R);

hyearR = figure;
xmin = juliandate(2011,1,1);
xmax = juliandate(2012,1,1);
binwidth = 7;
x=xmin:binwidth:xmax;
hist(jdYearlyR,x)
xlim([xmin,xmax]);
ylim([0,90]);
tickwidth = (xmax - xmin);
set(gca,'XTick',xmin:tickwidth:xmax)
title('Yearly right')
xlabel('UTC')
ylabel('number of events')
set(gca,'XTickLabel',{'1/1','1/1'})

cyearR = figure;
cdfplot(jdYearlyR)
xmin = juliandate(2011,1,1);
xmax = juliandate(2012,1,1);
xlim([xmin,xmax]);
tickwidth = (xmax - xmin);
set(gca,'XTick',xmin:tickwidth:xmax)
set(gca,'XTickLabel',{'1/1','1/1'})
title('CDF - Yearly right')
xlabel('UTC')



%day plot
H = utc2y_vec(:,4);
MN = utc2y_vec(:,5);
S = utc2y_vec(:,6);
utcDaily = H + MN./60 + S./60./60;

hdaily = figure;
x=0.5:1:23.5;
hist(utcDaily,x)
xlim([0,24]);
title('Daily (right&left)')
xlabel('UTC [hour]')
ylabel('number of events')
tcksX = {'0','','','3','','','6','','','9','','','12','','','15','','','18','','','21','','','24'};
set(gca,'XTick',0:1:24)
set(gca,'XTickLabel',tcksX)

cdaily = figure;
cdfplot(utcDaily)
xlim([0,24]);
set(gca,'XTick',0:3:24)
title('CDF - Daily (right&left)')
xlabel('UTC [hour]')

%day plot Right (241 events)
H = utcR_vec(:,4);
MN = utcR_vec(:,5);
S = utcR_vec(:,6);
utcDailyR = H + MN./60 + S./60./60;

hdailyR = figure;
x=0.5:1:23.5;
hist(utcDailyR,x)
xlim([0,24]);
title('Daily Accurate right')
xlabel('UTC [hour]')
ylabel('number of events')
tcksX = {'0','','','3','','','6','','','9','','','12','','','15','','','18','','','21','','','24'};
set(gca,'XTick',0:1:24)
set(gca,'XTickLabel',tcksX)

cdailyR = figure;
cdfplot(utcDailyR)
xlim([0,24]);
set(gca,'XTick',0:3:24)
title('CDF - Daily Accurate right)')
xlabel('UTC [hour]')

%day plot Left (145 events)
H = utcL_vec(:,4);
MN = utcL_vec(:,5);
S = utcL_vec(:,6);
utcDailyL = H + MN./60 + S./60./60;

hdailyL = figure;
x=0.5:1:23.5;
hist(utcDailyL,x)
xlim([0,24]);
ylim([0,18]);
title('Daily Accurate right')
xlabel('UTC [hour]')
ylabel('number of events')
tcksX = {'0','','','3','','','6','','','9','','','12','','','15','','','18','','','21','','','24'};
set(gca,'XTick',0:1:24)
set(gca,'XTickLabel',tcksX)

cdailyL = figure;
cdfplot(utcDailyL)
xlim([0,24]);
set(gca,'XTick',0:3:24)
title('CDF - Daily Accurate right)')
xlabel('UTC [hour]')

cd('PlotEventTimeHistCDF')
print(h2011R,'-depsc','histTime2011R.eps')
print(c2011R,'-depsc','CDFTime2011R.eps')
print(h2010R,'-depsc','histTime2010R.eps')
print(c2010R,'-depsc','CDFTime2010R.eps')
print(h2010L,'-depsc','histTime2010L.eps')
print(c2010L,'-depsc','CDFTime2010L.eps')
print(h2010,'-depsc','histTime2010.eps')
print(c2010,'-depsc','CDFTime2010.eps')
print(hyear,'-depsc','histTimeYearly.eps')
print(cyear,'-depsc','CDFTimeYearly.eps')
print(h2y,'-depsc','histTime2y.eps')
print(c2y,'-depsc','CDFTime2y.eps')
print(hyearR,'-depsc','histTimeYearlyR.eps')
print(cyearR,'-depsc','CDFTimeYearlyR.eps')
print(hdaily,'-depsc','histTimeDaily.eps')
print(cdaily,'-depsc','CDFTimeDaily.eps')
print(hdailyR,'-depsc','histTimeDailyR.eps')
print(cdailyR,'-depsc','CDFTimeDailyR.eps')
print(hdailyL,'-depsc','histTimeDailyL.eps')
print(cdailyL,'-depsc','CDFTimeDailyL.eps')
cd('../')