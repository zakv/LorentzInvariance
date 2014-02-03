function [] = set_for_shift_time_graph(time)
%Sets plot for time distribution(clock time from 23pm against date)

hold on;
set(gca, 'YDir','rev')
set(gca,'Box','on')
timeMin = min(time);
timeMax = max(time);

if timeMax - timeMin <= 70
    axis equal tight;
    if weekday(timeMin) == 1
        xMin = floor(timeMin) - 6;
    else
        xMin = floor(timeMin) - weekday(timeMin) + 2;
    end
    if weekday(timeMax) == 1
        xMax = floor(timeMax) + 1;
    else
        xMax = floor(timeMax) - weekday(timeMax) + 9;
    end
    set(gca,'XTick',xMin:7:xMax)
    datetick('x','mmm-dd','keepticks');
else
    [YMin,MMin,~,~,~,~] = datevec(timeMin);
    [YMax,MMax,~,~,~,~] = datevec(timeMax);
    xMin = datenum(YMin,MMin,1,0,0,0);
    xMax = datenum(YMax,MMax+1,1,0,0,0);
    datetick('x','mmm','keeplimits')
end

xlim([xMin,xMax])
ylim([-1,23])

set(gca,'YTick',-1:8:23)
set(gca,'YTickLabel',{'23','7','15','23'})

plot([xMin xMax], [7 7],'r');
hold on;
plot([xMin xMax], [15 15], 'r');
