function [time] = get_starting_time(runNumber,logtype)
%Gets first clock time that appears on elog for each run
iMax = numel(runNumber);
time = zeros(size(runNumber));

for i = 1:iMax
    
    dataDir1 = '../../DataSets/RawData/elogData';
    dataDir2='../../DataSets/RawData/FailedElogData';
    
    %figure out html file name from runNumber
    fileNamePattern1=strcat('(^run_|^)',int2str(runNumber(i)),'_\d*.html');
    fileNamePattern2=strcat('^',int2str(runNumber(i)),'.html');
    dirList1=dir(dataDir1);
    dirList2=dir(dataDir2);
    fileNameFound=false;
    if strcmp(logtype,'elog') ==1
        for j=1:length(dirList1)
            if ~isempty(regexp(dirList1(j).name,fileNamePattern1,'match'))
                fileName=fullfile(dataDir1,dirList1(j).name);
                fileNameFound=true;
            end
        end
    else if strcmp(logtype,'DataLog') == 1 || strcmp(logtype,'dataLog') == 1
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
                              int2str(runNumber(i)));
                          disp(dispString);
                          time(i)=NaN;
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
                    if strcmp(logtype,'elog') ==1
                        dispString=strcat('Found multiple dates for runNumber=',int2str(runNumber(i)));
                    else if strcmp(logtype,'DataLog') == 1 || strcmp(logtype,'dataLog') == 1
                            dispString=strcat('Found multiple dates for DataLogNumber=',int2str(runNumber(i)));
                        end
                            disp(dispString)
                    end
                            
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
            if strcmp(logtype,'elog') ==1
                dispString=strcat('Failed to find date for runNumber=',int2str(runNumber(i)));
            else if strcmp(logtype,'DataLog') == 1 || strcmp(logtype,'dataLog') == 1
                    dispString=strcat('Failed to find date for DataLogNumber=',int2str(runNumber(i)));
                end
                disp(dispString)
            end
        end
        if ~timeCalClockFound
            if strcmp(logtype,'elog') ==1
                dispString=strcat('Failed to find clock time calibration for runNumber=',int2str(runNumber(i)));
            else if strcmp(logtype,'DataLog') == 1 || strcmp(logtype,'dataLog') == 1
                    dispString=strcat('Failed to find clock time calibration for DataLogNumber=',int2str(runNumber(i)));
                end
                disp(dispString)
            end

        end
        if  ~dateFound || ~timeCalClockFound
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
                %and time of events   
            %disp(year);disp(month);disp(day);disp(hour);disp(minute);disp(second);

            %Finally, calculate time using datenum
            time(i)=datenum(year,month,day,hour,minute,second);
        end
    end
end
end