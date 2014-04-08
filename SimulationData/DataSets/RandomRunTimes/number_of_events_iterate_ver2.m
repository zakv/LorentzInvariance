function [] = number_of_events_iterate_ver2(iterationNumber)

dispstr = ['generate_event_time_',num2str(iterationNumber),'iteration.dat'];
fileID = fopen(dispstr,'w');
for i = 1:iterationNumber
    if mod(i,1000) == 0
        dispstr = ['i=',num2str(i)];
        disp(dispstr)
    end
    generate_event_times_ver3_2(fileID);
end
fclose(fileID);

fileData = importdata(dispstr);
eventN = fileData(:,1);
runN = fileData(:,2);
runSpan = fileData(:,3);

f_eventN = figure;
hist(eventN)
str = [num2str(iterationNumber),'iterations, ','mean=',num2str(mean(eventN)),', std=',num2str(std(eventN))];
title(str);
xlabel('number of events');
ylabel('count');

f_runN = figure;
hist(runN)
str = [num2str(iterationNumber),'iterations, ','mean=',num2str(mean(runN)),', std=',num2str(std(runN))];
title(str);
xlabel('number of runs');
ylabel('count');

f_runSpan = figure;
hist(runSpan)
str = [num2str(iterationNumber),'iterations, ','mean=',num2str(mean(runSpan)),', std=',num2str(std(runSpan))];
title(str);
xlabel('sum of experiment operating time');
ylabel('count');

saveas(f_eventN,'eventN.pdf','pdf');
saveas(f_runN,'runN.pdf','pdf');
saveas(f_runSpan,'runSpan.pdf','pdf');

disp('[Experiment]');
disp('eventN=386, runN=320, runSpan=34.8347');

end

