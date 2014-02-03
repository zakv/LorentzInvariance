% Generates EventTimeData.mat which contains following information
%   run20** : run number
%   st20**, utc20**, jd20** : event time in standard Swiss time,
%   UTC(universal), julian date format of UTC
%   type : type of event time (how the event time is calculated)
%          1 for event time via MCP
%          2 for event time via CsI
%          3 for event time via Matt (accurate to a minute)
%          4 for MCP time (accurate to a minute before 10/4/2011, from the day, four minutes)
%   Function ends with '_a' excludes inaccurate event time information

clear all;
close all;

oldDir = cd('../../DataSets/');
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

eventTime2011_a = get_accurate_event_time(run2011);
run2011R_a = eventTime2011_a(:,1);
st2011R_a = eventTime2011_a(:,2);
type2011R_a = eventTime2011_a(:,3);
utc2011R_a = st2utc_ch(st2011R_a);
jd2011R_a = datenum2jd(utc2011R_a);

eventTime2010R_a = get_accurate_event_time(run2010R);
run2010R_a = eventTime2010R_a(:,1);
st2010R_a = eventTime2010R_a(:,2);
type2010R_a = eventTime2010R_a(:,3);
utc2010R_a = st2utc_ch(st2010R_a);
jd2010R_a = datenum2jd(utc2010R_a);

eventTime2010L_a = get_accurate_event_time(run2010L);
run2010L_a = eventTime2010L_a(:,1);
st2010L_a = eventTime2010L_a(:,2);
type2010L_a = eventTime2010L_a(:,3);
utc2010L_a = st2utc_ch(st2010L_a);
jd2010L_a = datenum2jd(utc2010L_a);

save('EventTimeData','run2011R','st2011R','utc2011R','jd2011R','type2011R',...
    'run2010R','st2010R','utc2010R','jd2010R','type2010R',...
    'run2010L','st2010L','utc2010L','jd2010L','type2010L',...
    'run2011R_a','st2011R_a','utc2011R_a','jd2011R_a','type2011R_a',...
    'run2010R_a','st2010R_a','utc2010R_a','jd2010R_a','type2010R_a',...
    'run2010L_a','st2010L_a','utc2010L_a','jd2010L_a','type2010L_a');