function [A] = get_attempted_entry_time(runNumber)

%Returns time of events for a given runNumber.  Looks for files in
%dataDir,set early in this function.
%   Gets date from line near "Entry time"
%   Gets relative time of events from line above the one that starts with
%   the following: "Run   Event#"
%   The relative time is calibrated to real time by assuming CsI2
%   time(real time) is recorded when initial e catch happened(relative time).
%   If the hour of this calibration time is larger than the hour of the
%   entry time, then it is assumed that it comes from the day before, and
%   the "day" parameter given to datenum is adjusted accordingly.

iMax = numel(runNumber);
time = zeros(size(runNumber));
totalLength = 0;
Alength = 10000;
A = zeros(Alength,4);

for i = 1:iMax
    
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
        datePattern='^\s*(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s*(?<month>(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\s*';
        datePattern=strcat(datePattern,'(?<day>\d*)\s*(?<year>\d*),\s*(?<hour>\d*):(?<minute>\d*)\s*\|\s*Run:(?<run>\d*)\s*\|\s*DataLog:(?<datalog>\d*)\s*\|\s*(Pbar\s*Log\s*\|(\s*\[Trapping\])?|Trapping\s*Series\s*\|)\s*(Trapping\s*)?(S|s)eries\s*(?<series>\d*)\s*');
        dateFound=false;
        fileID=fopen(fileName);
        %iterate over lines of html file
        lineText=fgetl(fileID);
        run = zeros(100,1);
        datalog = zeros(100,1);
        series = zeros(100,1);           
        j=0;
        
        B = zeros(100,4);
        
        while ischar(lineText)
            if ~isempty(regexp(lineText,datePattern, 'once'))
                dateFound=1;
                j=j+1;
                dateMatch=regexp(lineText,datePattern,'names','once');
                %disp(dateMatch);
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
                hour=str2double(dateMatch.hour);
                minute=str2double(dateMatch.minute);
                run(j)=str2double(dateMatch.run);
                datalog(j)=str2double(dateMatch.datalog);
                series(j)=str2double(dateMatch.series);
                time(j)=datenum(year,month,day,hour,minute,0);
                C = [time(j),run(j),datalog(j),series(j)];
                B(j,:) = C;
            end
            lineText=fgetl(fileID);
        end
        fclose(fileID);
        
        if ~dateFound
            dispString=strcat('Failed to find date for runNumber=', ...
                              int2str(runNumber(i)));
            disp(dispString);
        end
        totalLength = totalLength + j;
        if any(B)==1
            if i==1
                A(1:j,:) = B(1:j,:);
            else
            A(1:totalLength,:)=vertcat(A(1:totalLength-j,:),B(1:j,:));
            end
        end
    end
end
A(totalLength+1:Alength,:) = [];

end