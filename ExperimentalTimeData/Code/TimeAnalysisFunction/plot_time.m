function [] = plot_time(time)
%Plots clock time (11pm - 11pm) against date

time = sort(time);
[~, ~, ~, H, MN, S] = datevec(time);
clockTime = H + MN./60 + S./3600.;
iMax = numel(clockTime);
for i = 1:iMax
    if H(i) >= 23
        clockTime(i) = clockTime(i) - 24;
    end
end
plot(time, clockTime,'+');

