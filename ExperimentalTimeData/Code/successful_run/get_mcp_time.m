function [ time ] = get_mcp_time(runNumber)
%Returns MCP image time for a given runNumber.  Looks for files in
%dataDir,set early in this function.
%   Gets date from line near "Entry time"
%   Gets time when MCP image was taken.
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
        datePattern='\s*MCP\s*Image:\s*(?<year>\d*)\.(?<month>\d*)\.(?<day>\d*)\s*(?<hour>\d*):(?<minute>\d*):(?<second>\d*\.\d*)\s*';
        dateFound=false;
        fileID=fopen(fileName);
        %iterate over lines of html file
        lineText=fgetl(fileID);
        while ischar(lineText)
            if ~isempty(regexp(lineText,datePattern, 'once'))
                dateMatch=regexp(lineText,datePattern,'names');
                if dateFound==true
                    dispString=strcat('Found multiple dates for runNumber=',int2str(runNumber(i)));
                    disp(dispString)
                end
                dateFound=true;
                %disp(dateMatch)
            end
            lineText=fgetl(fileID);
        end
        fclose(fileID);

        if ~dateFound
            dispString=strcat('Failed to find MCP date for runNumber=', ...
                              int2str(runNumber(i)));
            disp(dispString)
        end
        if  ~dateFound
            time(i) = NaN;
        else
            %Interpret regex matches to get info for datenum
            year=str2double(dateMatch.year);
            month=str2double(dateMatch.month);
            day=str2double(dateMatch.day);
            hour=str2double(dateMatch.hour);
            minute=str2double(dateMatch.minute);
            second=str2double(dateMatch.second);
            time(i)=datenum(year,month,day,hour,minute,second);
        end
    end
end