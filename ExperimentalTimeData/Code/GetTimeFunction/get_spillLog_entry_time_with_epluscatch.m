function [A] = get_spillLog_entry_time_with_epluscatch(dataLogNumber)

%Returns time of events for a given dataLog if there "initial e+ Catch occurs".
%Looks for files in dataDir,set early in this function.
%   Gets "Entry time"
% returns [time, run, datalog];

iMax = numel(dataLogNumber);
time = zeros(size(dataLogNumber));
run = zeros(size(dataLogNumber));
k = 0;
A = zeros(iMax,3);

for i = 1:iMax
    
    dataDir='../../DataSets/RawData/spillLog';
    
    %figure out html file name from dataLogNumber
    fileNamePattern=strcat('^',int2str(dataLogNumber(i)),'.html');
    dirList=dir(dataDir);
    fileNameFound=false;
    for j=1:length(dirList)
        if ~isempty(regexp(dirList(j).name,fileNamePattern,'match'))
            fileName=fullfile(dataDir,dirList(j).name);
            fileNameFound=true;
        end
    end

    if fileNameFound==false
        dispString=strcat('Failed to find file for dataLogNumber=', ...
                              int2str(dataLogNumber(i)));
                          disp(dispString);
                          time(i)=NaN;
    else

        %regex the necessary stuff
        %datePattern='^\s*(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s*(?<month>(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\s*';
        datePattern='(Entry\s*time:&nbsp;\s*<b>|^)\s*(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s*(?<month>(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\s*';
        datePattern=strcat(datePattern,'(?<day>\d*)\s*(?<year>\d*),\s*(?<hour>\d*):(?<minute>\d*)\s*(</b>)?$');
        dateFound=false;
        runPattern='^<tr><td\s*class="messageframe"><pre>Run\s*(?<run>\d*)$';
        %runPattern='<input\s*type=hidden\s*name="Run"\s*value="(?<run>\d*)">$';
        runFound=false;
        
        eplusPattern='\s*\|\s*Initial\s*e\+\s*Catch\s*\[[\d.]*\-[\d.]*\]=';
        eplusFound=false;
        fileID=fopen(fileName);
        %iterate over lines of html file
        lineText=fgetl(fileID);
        while ischar(lineText)
            if ~isempty(regexp(lineText,datePattern, 'once'))
                dateMatch=regexp(lineText,datePattern,'names');
                if dateFound==true
                    dispString=strcat('Found multiple dates for dataLogNumber=',int2str(dataLogNumber(i)));
                    disp(dispString)
                end
                dateFound=true;
            elseif ~isempty(regexp(lineText,runPattern,'once')) && dateFound
                runMatch=regexp(lineText,runPattern,'names','once');
                runFound=1;
            elseif ~isempty(regexp(lineText,eplusPattern,'once')) && dateFound &&runFound
                eplusFound=1;
            end
            lineText=fgetl(fileID);
        end
        fclose(fileID);
        
        if ~runFound
            dispString=strcat('Failed to find run number for dataLogNumber=',...
                int2str(dataLogNumber(i)));
            disp(dispString);
        end
        
        if ~dateFound
            dispString=strcat('Failed to find date for dataLogNumber=', ...
                              int2str(dataLogNumber(i)));
            disp(dispString)
        end
        
        if ~eplusFound
            dispString = strcat('Failed to find initial e+ catch for dataLogNumber=',...
                int2str(dataLogNumber(i)));
            disp(dispString)
        end
        
        if eplusFound && dateFound && runFound
            k = k+1;
            %Interpret regex matches to get info for datenum
            run(k)=str2double(runMatch.run);
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
            time(k)=datenum(year,month,day,hour,minute,0);
            A(k,:) = [time(k),run(k),dataLogNumber(i)];
        end
    end
end

if k<iMax
    A(k+1:iMax,:) = [];
end

end