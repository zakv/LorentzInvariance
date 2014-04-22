% Generates EventTimeData.mat which contains following information
%   run20** : run number
%   st20**, utc20**, jd20** : event time in standard Swiss time,
%   UTC(universal), julian date format of UTC
%   type : type of event time (how the event time is calculated)
%          1 for event time via MCP
%          2 for event time via CsI
%          3 for event time via Matt (accurate to a minute)
%          4 for MCP time (accurate to a minute before 10/4/2011, from the day, four minutes)

clear all;
close all;

oldDir = cd('../../DataSets/RawData/eventTimeData');
load('RunData');
cd(oldDir);

eventTime2011 = get_event_time(run2011);
run2011R = run2011;
st2011R = eventTime2011(:,2);
type2011R = eventTime2011(:,3);
utc2011R = st2utc_ch(st2011R);
jd2011R = datenum2jd(utc2011R);

eventTime2010R = get_event_time(run2010R);
st2010R = eventTime2010R(:,2);
type2010R = eventTime2010R(:,3);
utc2010R = st2utc_ch(st2010R);
jd2010R = datenum2jd(utc2010R);

eventTime2010L = get_event_time(run2010L);
st2010L = eventTime2010L(:,2);
type2010L = eventTime2010L(:,3);
utc2010L = st2utc_ch(st2010L);
jd2010L = datenum2jd(utc2010L);

save('EventTimeData','run2011R','st2011R','utc2011R','jd2011R','type2011R',...
    'run2010R','st2010R','utc2010R','jd2010R','type2010R',...
    'run2010L','st2010L','utc2010L','jd2010L','type2010L');