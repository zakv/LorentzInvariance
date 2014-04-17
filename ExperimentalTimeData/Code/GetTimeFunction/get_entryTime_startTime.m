function [entryTime,startTime] = get_entryTime_startTime(runNumber,logtype)
%Gets first clock time that appears on elog for each run
%logtype = 'elog' for successful run
%          'DataLog' or 'dataLog' for failed run

iMax = numel(runNumber);
entryTime = zeros(size(runNumber));
startTime = zeros(size(runNumber));

for i = 1:iMax
    
    dataDir1 = '../../DataSets/RawData/elogData';
    dataDir2='../../DataSets/RawData/FailedElogData';
    dataDir3='../../DataSets/RawData/SpillLog';
    
    %figure out html file name from runNumber
    fileNameFound=false;
    if strcmp(logtype,'elog') ==1 
    fileNamePattern1=strcat('(^run_|^)',int2str(runNumber(i)),'_\d*.html');
    dirList1=dir(dataDir1);
        for j=1:length(dirList1)
            if ~isempty(regexp(dirList1(j).name,fileNamePattern1,'match'))
                fileName=fullfile(dataDir1,dirList1(j).name);
                fileNameFound=true;
            end
        end
    end
    if strcmp(logtype,'DataLog') == 1 || strcmp(logtype,'dataLog') == 1
    fileNamePattern2=strcat('^',int2str(runNumber(i)),'.html');
    dirList2=dir(dataDir2);
       for j=1:length(dirList2)
            if ~isempty(regexp(dirList2(j).name,fileNamePattern2,'match'))
                fileName=fullfile(dataDir2,dirList2(j).name);
                fileNameFound=true;
            end
        end
    end
    if strcmp(logtype,'spillLog') == 1 || strcmp(logtype,'DataLog') == 1
    fileNamePattern3=strcat('^',int2str(runNumber(i)),'.html');
    dirList3=dir(dataDir3);
        for j=1:length(dirList3)
            if ~isempty(regexp(dirList3(j).name,fileNamePattern3,'match'))
                fileName=fullfile(dataDir3,dirList3(j).name);
                fileNameFound=true;
            end
        end
    end
    if fileNameFound == 0
            disp('wrong imput for logtype');
    end

    if fileNameFound==false
        dispString=strcat('Failed to find file for runNumber=', ...
                              int2str(runNumber(i)));
                          disp(dispString);
                          entryTime(i)=NaN;
                          startTime(i)=NaN;
    else

        %regex the necessary stuff
        %datePattern='^\s*(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s*(?<month>(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\s*';
        datePattern='(Entry\s*time:&nbsp;\s*<b>|^)\s*(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s*(?<month>(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\s*';
        datePattern=strcat(datePattern,'(?<day>\d*)\s*(?<year>\d*),\s*(?<hour>\d*):(?<minute>\d*)\s*(</b>)?$');
        dateFound=false;
        timeCalClockPattern='\s*\[(?<hour>\d*):(?<minute>\d*):(?<second>\d*)\]\s*';
        timeCalClockFound=false;
        fileID=fopen(fileName);
        %iterate over lines of html file
        lineText=fgetl(fileID);
        while ischar(lineText)
            if ~isempty(regexp(lineText,datePattern, 'once'))
                dateMatch=regexp(lineText,datePattern,'names');
                if dateFound==true
                    dispString=strcat('Found multiple dates for Number=',int2str(runNumber(i)));
                    disp(dispString)
                end
                dateFound=true;
                %disp(dateMatch)
            elseif (~isempty(regexp(lineText,timeCalClockPattern, 'once')) && ~timeCalClockFound)
                timeCalClockMatch=regexp(lineText,timeCalClockPattern,'names');
                timeCalClockFound=true;
                %disp(timeCalClockMatch)
            end
            lineText=fgetl(fileID);
        end
        fclose(fileID);
        if ~dateFound
            dispString=strcat('Failed to find date for Number=',int2str(runNumber(i)));
            disp(dispString)
        end
        if ~timeCalClockFound
            dispString=strcat('Failed to find clock time calibration for runNumber=',int2str(runNumber(i)));
            disp(dispString)
        end
        if  ~dateFound
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
            %calculate entry time
            entryTime(i)=datenum(year,month,day,hour_entry,minute_entry,0);
            
            if ~timeCalClockFound
            startTime(i) = NaN;
            else
                hour_start=str2double(timeCalClockMatch.hour);
                minute_start=str2double(timeCalClockMatch.minute);
                second_start=str2double(timeCalClockMatch.second);
                if hour_entry<hour_start
                    %If this is the case, timeCalClock must be from the day before dateMatch
                    day=day-1;
                end
                %calculate starting time
            startTime(i)=datenum(year,month,day,hour_start,minute_start,second_start);
            end
        end
    end
end
end