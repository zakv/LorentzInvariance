function [] = plot_time_from_0am(time)
%Plots clock time (0am-0am) against date

time = sort(time);
[~, ~, ~, H, MN, S] = datevec(time);
clockTime = H + MN./60 + S./3600.;
plot(time, clockTime,'+');

