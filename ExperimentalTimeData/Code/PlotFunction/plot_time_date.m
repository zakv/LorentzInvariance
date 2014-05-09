function [] = plot_time_date(time,color)
%Plots clock time against date

time = sort(time);
[~, ~, ~, H, MN, S] = datevec(time);
clockTime = H + MN./60 + S./3600.;

%if you wanna plot from 23:00...
%clockTime(H>=23) = clockTime(H>=23) - 24;
style = ['+',color];
plot(time, clockTime,style);

