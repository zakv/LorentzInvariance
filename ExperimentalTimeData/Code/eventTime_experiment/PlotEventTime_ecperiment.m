%creat a file that includes actual event time.
%It is a more practicable and organized virsion of EventTimeData.mat

oldDir = cd('../../Class/');

successful = successful_run();

%get time
eventTime_utc = successful.eventTime('utc', 'all','all');
eventTime_utc = sort(eventTime_utc);
eventTime_local = eventTime_utc + datenum(0,0,0,1,0,0);

eventTime_utc_r = successful.eventTime('utc','all','right');
eventTime_utc_r = sort(eventTime_utc_r);
eventTime_utc_l = successful.eventTime('utc','all','left');
eventTime_utc_l = sort(eventTime_utc_l);

eventTime_local_r = eventTime_utc_r + datenum(0,0,0,1,0,0);
eventTime_local_l = eventTime_utc_l + datenum(0,0,0,1,0,0);

%save data
cd(oldDir);
oldDir2 = cd('../../DataSets/eventTime_experiment/');
save('eventTime_experiment','eventTime_utc','eventTime_utc_r','eventTime_utc_l',...
    'eventTime_local','eventTime_local_r','eventTime_local_l');
cd(oldDir2);

clear all;
