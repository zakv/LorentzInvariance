%Generates quench time of all attempted(both successful and failed) runs
% for successful time, this time is equal to event time

clear all;

t = event_time();
%successfulRun = t.run('all','all',0);
failedDataLog = t.failedDataLog();

%successfulQuenchTime = get_event_time(successfulRun,1);
failedQuenchTime = get_quench_dump_time(failedDataLog,0);

%attemptedQuenchTime = vertcat(successfulQuenchTime,failedQuenchTime);

%oldDir = cd('../../DataSets');
%save('QuenchTimeData.mat','successfulQuenchTime','failedQuenchTime','attemptedQuenchTime');
%cd(oldDir);