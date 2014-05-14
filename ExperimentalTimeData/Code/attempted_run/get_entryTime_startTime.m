function [entryTime,startTime] = get_entryTime_startTime(logID,run,logtype)
%Gets first clock time that appears on elog for each run
%logtype = 'elog' or 'dataLog' for successful run
%          'elogData_all' or 'dataLog_all' for attempted run including successful runs

%need to exclude run 27096! (datalog:27530,spilllog:15303)
% It says "attempt" in Subject, but obviously not a trapping attempt.

iMax = numel(logID);
entryTime = zeros(size(logID));
startTime = zeros(size(logID));

for i = 1:iMax
    
    dataDir1 = '../../DataSets/RawData/elogData';
    dataDir2='../../DataSets/RawData/elogData_all';
    dataDir3='../../DataSets/RawData/SpillLog';
    fileNamePattern1=strcat('(^run\d*_|^\d*_)',int2str(logID(i)),'.html');
    fileNamePattern2=strcat('^',int2str(logID(i)),'.html');

    %figure out html file name from runNumber
    fileNameFound=false;
    if strcmp(logtype,'elog') ==1 || strcmp(logtype,'dataLog') == 1
        fileNamePattern = fileNamePattern1;
        dataDir = dataDir1;
    elseif strcmp(logtype,'elogData_all') == 1 || strcmp(logtype,'dataLog_all') == 1
        fileNamePattern = fileNamePattern2;
        dataDir = dataDir2;
    elseif strcmp(logtype,'spillLog') == 1
        fileNamePattern = fileNamePattern2;
        dataDir = dataDir3;
    else
        disp('wrong imput for logtype');
    end
            
    %look for html file
    dirList=dir(dataDir);
    for j=1:length(dirList)
        if ~isempty(regexp(dirList(j).name,fileNamePattern,'match'))
            fileName=fullfile(dataDir,dirList(j).name);
            fileNameFound=true;
        end
    end

    if fileNameFound==false
        dispString=['Failed to find file for ',logtype,'=', ...
                              int2str(logID(i))];
                          disp(dispString);
                          entryTime(i)=NaN;
                          startTime(i)=NaN;
    else
        %regex the necessary stuff
        %datePattern='^\s*(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s*(?<month>(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\s*';
        datePattern='(Entry\s*time:&nbsp;\s*<b>|^)\s*(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s*(?<month>(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\s*';
        datePattern=strcat(datePattern,'(?<day>\d*)\s*(?<year>\d*),\s*(?<hour>\d*):(?<minute>\d*)\s*(</b>)?$');
        dateFound=false;
        runPattern=['^Run\s',num2str(run(i)),'$'];
        runFound=false;
        timeClockPattern='\s*\[(?<hour>\d*):(?<minute>\d*):(?<second>\d*)\]\s*';
        timeClockFound=false;
        fileID=fopen(fileName);
        %iterate over lines of html file
        lineText=fgetl(fileID);
        while ischar(lineText)
            if ~isempty(regexp(lineText,datePattern, 'once'))
                dateMatch=regexp(lineText,datePattern,'names');
                if dateFound==true
                    dispString=['Found multiple dates for ',logtype,'=',int2str(logID(i))];
                    disp(dispString)
                end
                dateFound=true;
                %disp(dateMatch)
            elseif ~isempty(regexp(lineText,runPattern,'once')) && ~runFound
                runFound=1;
            elseif ~isempty(regexp(lineText,timeClockPattern,'once')) && ~timeClockFound
                timeClockMatch=regexp(lineText,timeClockPattern,'names');
                hour_start=str2double(timeClockMatch.hour);
                minute_start=str2double(timeClockMatch.minute);
                second_start=str2double(timeClockMatch.second);
                %to avoid getting automatic time stamp at 1:00:00
                if ~(hour_start==1 && minute_start==0 && second_start==0)
                    timeClockFound=true;
                end
                %disp(timeClockMatch)
            end
            lineText=fgetl(fileID);
        end
        fclose(fileID);
        
        if ~timeClockFound
            dispString=['Failed to find clock time for ',logtype,'=',int2str(logID(i))];
            disp(dispString)
        end
        
        if  ~dateFound
            dispString=['Failed to find date for Number=',int2str(logID(i))];
            disp(dispString)
            entryTime(i) = NaN;
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
            hour_entry=str2double(dateMatch.hour);
            minute_entry=str2double(dateMatch.minute);
            entryTime(i)=datenum(year,month,day,hour_entry,minute_entry,0);
            %calculate entry time
            if ~timeClockFound
            startTime(i) = NaN;
            else
                %when startTime < entryTime, and different day
                if hour_start - hour_entry > 12
                    %If this is the case, timeClock must be from the day before dateMatch
                    day=day-1;
                    dispstr=['Running till the next day for run=',num2str(run(i))];
                    disp(dispstr);
                end
                %when entryTime < startTime, and different day
                if hour_entry - hour_start > 12
                    day = day + 1;
                    dispstr=['Running till the next day for run=',num2str(run(i))];
                    disp(dispstr);
                end
                %calculate starting time
            startTime(i)=datenum(year,month,day,hour_start,minute_start,second_start);
            end
        end
    end
end

end