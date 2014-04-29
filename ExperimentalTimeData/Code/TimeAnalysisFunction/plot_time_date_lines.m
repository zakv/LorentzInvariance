function [] = plot_time_date_lines(times)

[~, ~, ~, H, MN, S] = datevec(times);
ClockTime = H + MN./60 + S./3600.;
StartDate = times - ClockTime/24;

for i = 1:numel(times)
    x = [StartDate(i); StartDate(i)+1];
    y = [ClockTime(i); ClockTime(i)];
    plot(x,y,'g')
    hold on
end
end