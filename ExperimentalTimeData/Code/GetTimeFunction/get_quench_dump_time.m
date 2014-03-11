function [time] = get_quench_dump_time(Number,logtype)

%Returns time when quench dump happens for a given runNumber.
%   (same as event time for successful run)
%Looks for files in dataDir,set early in this function.
%   Gets date from line near "Entry time"
%   Gets relative time of events from line above the one that starts with
%   the following: "Run   Event#"
%   The relative time is calibrated to real time by assuming CsI2
%   time(real time) is recorded when initial e catch happened(relative time).
%   If the hour of this calibration time is larger than the hour of the
%   entry time, then it is assumed that it comes from the day before, and
%   the "day" parameter given to datenum is adjusted accordingly.
%
%   [Input]   
%    for successful run
%       Number = run number, logtype = 1 or 'elog'
%    for failed run
%       Number = dataLog number, logtype = 0 or 'DataLog' or 'dataLog'


iMax = numel(Number);
time = zeros(size(Number));

for i = 1:iMax
    
    dataDir1 = '../../DataSets/RawData/elogData';
    dataDir2='../../DataSets/RawData/FailedElogData';
    
    %figure out html file name from runNumber
    fileNamePattern1=strcat('(^run_|^)',int2str(Number(i)),'_\d*.html');
    fileNamePattern2=strcat('^',int2str(Number(i)),'.html');
    dirList1=dir(dataDir1);
    dirList2=dir(dataDir2);
    fileNameFound=false;
    if strcmp(logtype,'elog') ==1 || logtype == 1
        for j=1:length(dirList1)
            if ~isempty(regexp(dirList1(j).name,fileNamePattern1,'match'))
                fileName=fullfile(dataDir1,dirList1(j).name);
                fileNameFound=true;
            end
        end
    else if strcmp(logtype,'DataLog') == 1 || strcmp(logtype,'dataLog') == 1 || logtype == 0
        for j=1:length(dirList2)
            if ~isempty(regexp(dirList2(j).name,fileNamePattern2,'match'))
                fileName=fullfile(dataDir2,dirList2(j).name);
                fileNameFound=true;
            end
        end
        else
            disp('wrong imput for logtype');
        end
    end

    if fileNameFound==false
        dispString=strcat('Failed to find file for runNumber=', ...
                              int2str(Number(i)));
                          disp(dispString);
                          time(i)=NaN;
    else

        %regex the necessary stuff
        %datePattern='^\s*(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s*(?<month>(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\s*';
        datePattern='(Entry\s*time:&nbsp;\s*<b>|^)\s*(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s*(?<month>(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\s*';
        datePattern=strcat(datePattern,'(?<day>\d*)\s*(?<year>\d*),\s*(?<hour>\d*):(?<minute>\d*)\s*(</b>)?$');
        dateFound=false;
        eventRelTimePattern='\s*\|\s*Quench\s*dump\s*\[(?<eventRelTime>[\d.]*)\-[\d.]*\]=';
        eventRelTimeFound=0;
        
        for k = 1:2
            if k == 1
            %potion1 : calibrates time using the time when Left dump happens
            %and when MCP image was taken
            timeCalRelPattern='\s*\|\s*Left\s*dump\s*\[(?<relTime>[\d.]*)\-[\d.]*\]=';
            timeCalRelFound=false;
            timeCalClockPattern='\s*MCP\s*Image:\s*\d*\.\d*\.\d*\s*(?<hour>\d*):(?<minute>\d*):(?<second>\d*\.\d*)\s*';
            timeCalClockFound=false;
            elseif k == 2
            %option2 : calibrates time using Initial e+ Catch and CsI2
            timeCalRelPattern='\s*\|\s*Initial\s*e\+\s*Catch\s*\[(?<relTime>[\d.]*)\-[\d.]*\]=';
            timeCalRelFound=false;
            timeCalClockPattern='\s*\[(?<hour>\d*):(?<minute>\d*):(?<second>\d*)\]\s*CsI2\s*=\s*[\d.]*\s*';
            timeCalClockFound=false; 
            end
            fileID=fopen(fileName);
            %iterate over lines of html file
            lineText=fgetl(fileID);
            while ischar(lineText)
                if (~isempty(regexp(lineText,datePattern, 'once')) && ~dateFound)
                    dateMatch=regexp(lineText,datePattern,'names');
                    if dateFound==true
                        dispString=strcat('Found multiple dates for runNumber=',int2str(Number(i)));
                        disp(dispString)
                    end
                    dateFound=true;
                    %disp(dateMatch)
                elseif (~isempty(regexp(lineText,timeCalRelPattern, 'once')) && ~timeCalRelFound)
                    timeCalRelMatch=regexp(lineText,timeCalRelPattern,'names');
                    timeCalRelFound=true;
                    %disp(timeCalRelMatch)
                elseif (~isempty(regexp(lineText,timeCalClockPattern, 'once')) && timeCalRelFound && ~timeCalClockFound)
                    timeCalClockMatch=regexp(lineText,timeCalClockPattern,'names');
                    timeCalClockFound=true;
                    %disp(timeCalClockMatch)
                elseif ~isempty(regexp(lineText,eventRelTimePattern, 'once'))
                    eventRelTimeMatch=regexp(lineText,eventRelTimePattern,'names');
                    if eventRelTimeFound>1
                        %This line appears twice, so if it's appeared twice already,
                        %there's a problem
                        dispString=strcat('Found multiple eventRelTimes for runNumber=',...
                                          int2str(Number(i)));
                        disp(dispString)
                    end
                    eventRelTimeFound=eventRelTimeFound+1;
                    %disp(eventRelTimeMatch)
                end
                lineText=fgetl(fileID);
            end
            fclose(fileID);

            if timeCalClockFound
                break
            end
        end

        if ~dateFound
            dispString=strcat('Failed to find date for runNumber=', ...
                              int2str(Number(i)));
            disp(dispString)
        end
        if ~timeCalRelFound
            dispString=strcat('Failed to find relative time calibration for runNumber=', ...
                              int2str(Number(i)));
            disp(dispString)
        end
        if ~timeCalClockFound
            dispString=strcat('Failed to find clock time calibration for runNumber=', ...
                              int2str(Number(i)));
            disp(dispString)
        end
        if eventRelTimeFound<1 %this line should appear twice; only need it once
            dispString=strcat('Failed to find quench dump time for runNumber=', ...
                              int2str(Number(i)));
            disp(dispString)
        end

        if  ~dateFound || ~timeCalRelFound || ~timeCalClockFound || (eventRelTimeFound <1 )
            time(i) = NaN;
        else
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
            if dateMatch.hour<timeCalClockMatch.hour
                %If this is the case, timeCalClock must be from the day before dateMatch
                day=day-1;
            end
            hour=str2double(timeCalClockMatch.hour);
            minute=str2double(timeCalClockMatch.minute);
            second=str2double(timeCalClockMatch.second);
            delta_t=str2double(eventRelTimeMatch.eventRelTime)-str2double(timeCalRelMatch.relTime);
            second=second+delta_t; %account for difference between time used for calibration
            %and time of events   
            %disp(year);disp(month);disp(day);disp(hour);disp(minute);disp(second);

            %Finally, calculate time using datenum
            time(i)=datenum(year,month,day,hour,minute,second);
        end
    end
end
end