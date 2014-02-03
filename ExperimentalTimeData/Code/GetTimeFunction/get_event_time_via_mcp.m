function [ time ] = get_event_time_via_mcp(runNumber)
%Returns time of events for a given runNumber.  Looks for files in
%dataDir,set early in this function.
%   Gets date from line near "Entry time"
%   Gets relative time of events from line above the one that starts with
%   the following: "Run   Event#"
%   The relative time is calibrated to real time using the the time when
%   MCP image was taken.
%   If the hour of this calibration time is larger than the hour of the
%   entry time, then it is assumed that it comes from the day before, and
%   the "day" parameter given to datenum is adjusted accordingly.

iMax = numel(runNumber);
time = zeros(size(runNumber));

for i=1:iMax
    
    dataDir='../../DataSets/RawData/elogData';
    
    %figure out html file name from runNumber
    fileNamePattern=strcat('(^run_|^)',int2str(runNumber(i)),'_\d*.html');
    dirList=dir(dataDir);
    fileNameFound=false;
    for j=1:length(dirList)
        if ~isempty(regexp(dirList(j).name,fileNamePattern,'match'))
            fileName=fullfile(dataDir,dirList(j).name);
            fileNameFound=true;
        end
    end

    if fileNameFound==false
            dispString=strcat('Failed to find file for runNumber=', ...
                              int2str(runNumber(i)));
                          disp(dispString);
                          time(i)=NaN;
    else
        %regex the necessary stuff
        timeCalPattern='\s*\|\s*Left\s*dump\s*\[(?<relTime>[\d.]*)\-[\d.]*\]=';
        timeCalFound=false;
        datePattern='\s*MCP\s*Image:\s*(?<year>\d*)\.(?<month>\d*)\.(?<day>\d*)\s*(?<hour>\d*):(?<minute>\d*):(?<second>\d*\.\d*)\s*';
        dateFound=false;
        eventRelTimePattern='^(?<eventRelTime>[\d.]+)\s*\-\&gt\;\s*[\d.]*\s*\[[\d.]*\s*s\]\s*$';
        eventRelTimeFound=0;
        fileID=fopen(fileName);
        %iterate over lines of html file
        lineText=fgetl(fileID);
        while ischar(lineText)
            if (~isempty(regexp(lineText,timeCalPattern, 'once')) && ~timeCalFound)
                timeCalMatch=regexp(lineText,timeCalPattern,'names');
                timeCalFound=true;
                %disp(timeCalMatch)
            elseif ~isempty(regexp(lineText,datePattern, 'once'))
                dateMatch=regexp(lineText,datePattern,'names');
                if dateFound==true
                    dispString=strcat('Found multiple dates for runNumber=',int2str(runNumber(i)));
                    disp(dispString)
                end
                dateFound=true;
                %disp(dateMatch)
            elseif ~isempty(regexp(lineText,eventRelTimePattern, 'once'))
                eventRelTimeMatch=regexp(lineText,eventRelTimePattern,'names');
                if eventRelTimeFound>1
                    %This line appears twice, so if it's appeared twice already,
                    %there's a problem
                    dispString=strcat('Found multiple eventRelTimes for runNumber=',...
                                      int2str(runNumber(i)));
                    disp(dispString)
                end
                eventRelTimeFound=eventRelTimeFound+1;
                %disp(eventRelTimeMatch)
            end
            lineText=fgetl(fileID);
        end
        fclose(fileID);

        if ~timeCalFound
            dispString=strcat('Failed to find time calibration for runNumber=', ...
                              int2str(runNumber(i)));
            disp(dispString)
        end
        if ~dateFound
            dispString=strcat('Failed to find MCP date for runNumber=', ...
                              int2str(runNumber(i)));
            disp(dispString)
        end
        if eventRelTimeFound<1 %this line should appear twice; only need it once
            dispString=strcat('Failed to find eventRelTime for runNumber=', ...
                              int2str(runNumber(i)));
            disp(dispString)
        end

        if  ~dateFound || ~timeCalFound || (eventRelTimeFound <1 )
            time(i) = NaN;
        else
            %Interpret regex matches to get info for datenum
            year=str2double(dateMatch.year);
            month=str2double(dateMatch.month);
            day=str2double(dateMatch.day);
            hour=str2double(dateMatch.hour);
            minute=str2double(dateMatch.minute);
            second=str2double(dateMatch.second);
            delta_t=str2double(eventRelTimeMatch.eventRelTime)-str2double(timeCalMatch.relTime);
            second=second+delta_t; %account for difference between time used for calibration
            %and time of events   
            %disp(year);disp(month);disp(day);disp(hour);disp(minute);disp(second);

            %Finally, calculate time using datenum
            time(i)=datenum(year,month,day,hour,minute,second);
        end
    end
end