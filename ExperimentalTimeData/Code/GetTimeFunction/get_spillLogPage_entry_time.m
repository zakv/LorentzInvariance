function [A] = get_spillLogPage_entry_time()

%Returns time of events for a given runNumber.  Looks for files in
%dataDir,set early in this function.
%   Gets "Entry time"
% returns [time, run, datalog];


iMin = 142; %142
iMax = 426; %426
totalLength = 0;
Alength = 10000;
A = zeros(Alength,3);

for i = iMin:iMax
    
    dataDir='../../DataSets/RawData/spillLogPage';
    
    %figure out html file name from runNumber
    fileNamePattern=strcat('(^page)',int2str(i),'.html');
    dirList=dir(dataDir);
    fileNameFound=false;
    
    for j=1:length(dirList)
        if ~isempty(regexp(dirList(j).name,fileNamePattern,'match'))
            fileName=fullfile(dataDir,dirList(j).name);
            fileNameFound=true;
        end
    end

    if fileNameFound==false
        dispString=strcat('Failed to find file for page=', ...
                              int2str(i));
                          disp(dispString);
    else
        %regex the necessary stuff
        numberPattern='\.\./SpillLog/(?<datalog>\d*)">(?<run>\d*)</a></td>\s*$';
        numberFound=false;
        datePattern='^\s*<td\s*class="list(1|2)"\s*nowrap><a\s*href="\.\./SpillLog/\d*">(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s*(?<month>(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec))\s*';
        datePattern=strcat(datePattern,'(?<day>\d*)\s*(?<year>\d*),\s*(?<hour>\d*):(?<minute>\d*)</a></td>');
        dateFound=false;
        fileID=fopen(fileName);
        %iterate over lines of html file
        lineText=fgetl(fileID);
        runIndex = 100;
        time = zeros(runIndex,1);
        run = zeros(runIndex,1);
        datalog = zeros(runIndex,1);
        j=0;
        
        B = zeros(runIndex,3);
        
        while ischar(lineText)
            if ~isempty(regexp(lineText,numberPattern,'once'))
                numberFound=1;
                j=j+1;
                numberMatch=regexp(lineText,numberPattern,'names','once');
                run(j)=str2double(numberMatch.run);
                datalog(j)=str2double(numberMatch.datalog);
            elseif ~isempty(regexp(lineText,datePattern, 'once'))
                dateFound=1;
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
                time(j)=datenum(year,month,day,hour,minute,0);
                C = [time(j),run(j),datalog(j)];
                B(j,:) = C;
            end
            lineText=fgetl(fileID);
        end
        fclose(fileID);
        
        if ~numberFound
            dispString=strcat('Failed to find run%dataLog number for pare',...
                int2str(i));
            disp(dispString);
        end
        if ~dateFound
            dispString=strcat('Failed to find date for page', ...
                              int2str(i));
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