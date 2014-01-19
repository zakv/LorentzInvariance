function [ time ] = GetTime(runNumber)
%Returns time of events for a given runNumber.  Looks for files in
%dataDir,set early in this function.
%   Gets date from line near "Entry time"
%   Gets relative time of events from line above the one that starts with
%   the following: "Run   Event#"
%   The relative time is calibrated to real time using the first line in
%   the log that contains both the real time and relative time, such as
%   the following "[00:20:25] | Background Before Pbars             [81.25"
%   If the hour of this calibration time is larger than the hour of the
%   entry time, then it is assumed that it comes from the day before, and
%   the "day" parameter given to datenum is adjusted accordingly.

dataDir='elog data';

%figure out html file name from runNumber
fileNamePattern=strcat('run_',int2str(runNumber),'_\d*.html');
dirList=dir(dataDir);
for j=1:length(dirList)
    if ~isempty(regexp(dirList(j).name,fileNamePattern,'match'))
        fileName=fullfile(dataDir,dirList(j).name);
    end
end

%regex the necessary stuff
datePattern='^\s*(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s*(?<month>(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\s*';
datePattern=strcat(datePattern,'(?<day>\d*)\s*(?<year>\d*),\s*(?<hour>\d*):(?<minute>\d*)$');
dateFound=false;
timeCalPattern='\[(?<hour>\d*):(?<minute>\d*):(?<second>\d*)\]\s*\|\s*[\w\s+]*\s*\[(?<relTime>[\d.]*)\-[\d.]*\]=';
timeCalFound=false;
eventRelTimePattern='^(?<eventRelTime>[\d.]+)\s*\-\&gt\;\s*[\d.]*\s*\[[\d.]*\s*s\]\s*$';
eventRelTimeFound=0;
fileID=fopen(fileName);
%iterate over lines of html file
lineText=fgetl(fileID);
while ischar(lineText)
    if ~isempty(regexp(lineText,datePattern, 'once'))
        dateMatch=regexp(lineText,datePattern,'names');
        if dateFound==true
            dispString=strcat('Found multiple dates for runNumber=',int2str(runNumber));
            disp(dispString)
        end
        dateFound=true;
        %disp(dateMatch)
    elseif (~isempty(regexp(lineText,timeCalPattern, 'once')) && ~timeCalFound)
        timeCalMatch=regexp(lineText,timeCalPattern,'names');
        timeCalFound=true;
        %disp(timeCalMatch)
    elseif ~isempty(regexp(lineText,eventRelTimePattern, 'once'))
        eventRelTimeMatch=regexp(lineText,eventRelTimePattern,'names');
        if eventRelTimeFound>1
            %This line appears twice, so if it's appeared twice already,
            %there's a problem
            dispString=strcat('Found multiple eventRelTimes for runNumber=',...
                              int2str(runNumber));
            disp(dispString)
        end
        eventRelTimeFound=eventRelTimeFound+1;
        %disp(eventRelTimeMatch)
    end
    lineText=fgetl(fileID);
end

if ~dateFound
    dispString=strcat('Failed to find date for runNumber=', ...
                      int2str(runNumber));
    disp(dispString)
end
if ~timeCalFound
    dispString=strcat('Failed to find time calibration for runNumber=', ...
                      int2str(runNumber));
    disp(dispString)
end
if eventRelTimeFound<1 %this line should appear twice; only need it once
    dispString=strcat('Failed to find eventRelTime for runNumber=', ...
                      int2str(runNumber));
    disp(dispString)
end

%Interpret regex matches to get info for datenum
year=str2double(dateMatch.year);
if strcmp(dateMatch.month,'Jan')
    month=1;
elseif strcmp(dateMatch.month,'Feb')
    month=2;
elseif strcmp(dateMatch.month,'Mar')
    month=3;
elseif strcmp(dateMatch.month,'Apr')
    month=4;
elseif strcmp(dateMatch.month,'May')
    month=5;
elseif strcmp(dateMatch.month,'Jun')
    month=6;
elseif strcmp(dateMatch.month,'Jul')
    month=7;
elseif strcmp(dateMatch.month,'Aug')
    month=8;
elseif strcmp(dateMatch.month,'Sep')
    month=9;
elseif strcmp(dateMatch.month,'Oct')
    month=10;
elseif strcmp(dateMatch.month,'Nov')
    month=11;
elseif strcmp(dateMatch.month,'Dec')
    month=12;
end
day=str2double(dateMatch.day);
if dateMatch.hour<timeCalMatch.hour
    %If this is the case, timeCal must be from the day before dateMatch
    day=day-1;
end
hour=str2double(timeCalMatch.hour);
minute=str2double(timeCalMatch.minute);
second=str2double(timeCalMatch.second);
delta_t=str2double(eventRelTimeMatch.eventRelTime)-str2double(timeCalMatch.relTime);
second=second+delta_t; %account for difference between time used for calibration
    %and time of events   
%disp(year);disp(month);disp(day);disp(hour);disp(minute);disp(second);

%Finally, calculate time using datenum
time=datenum(year,month,day,hour,minute,second);

end