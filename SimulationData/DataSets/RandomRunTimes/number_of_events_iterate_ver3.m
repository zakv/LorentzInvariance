function [] = number_of_events_iterate_ver3(iterationNumber)
%Iterate generate_event_time function and write/plot (1)total time span,
%(2) number of runs, and (3) number of events.
%To use this, change the output of generate_event_time function from 'eventTimes' to
%'iterationData', and comment out the plots.

%call the random generator class
addpath ../../Code/Classes/
random_generator = Random_Generator();

%get iteration data
iterationData = zeros(iterationNumber,3);
for i = 1:iterationNumber
    if mod(i,1000) == 0
        dispstr = ['i=',num2str(i)];
        disp(dispstr)
    end
    iterationData(i,:) = generate_event_times(random_generator);
end
n_events = iterationData(:,1);
n_runs = iterationData(:,2);
totalRunSpan = iterationData(:,3);

%save mat data
dispstr = ['generate_event_times_',num2str(iterationNumber),'iteration'];
save(dispstr,'n_events','n_runs','totalRunSpan');

%-----------------plot-----------------
f_eventN = figure;
hist(n_events)
str = [num2str(iterationNumber),'iterations, ','mean=',num2str(mean(n_events)),', std=',num2str(std(n_events))];
title(str);
xlabel('number of events');
ylabel('count');

f_runN = figure;
hist(n_runs)
str = [num2str(iterationNumber),'iterations, ','mean=',num2str(mean(n_runs)),', std=',num2str(std(n_runs))];
title(str);
xlabel('number of runs');
ylabel('count');

f_runSpan = figure;
hist(totalRunSpan)
str = [num2str(iterationNumber),'iterations, ','mean=',num2str(mean(totalRunSpan)),', std=',num2str(std(totalRunSpan))];
title(str);
xlabel('sum of experiment operating time');
ylabel('count');

saveas(f_eventN,'eventN.pdf','pdf');
saveas(f_runN,'runN.pdf','pdf');
saveas(f_runSpan,'runSpan.pdf','pdf');

%-------------display-----------------
disp('[Experiment]');
disp('eventN=386, runN=320, runSpan=34.8347 or 26.0125(_successfulShift)');

end

