function [ time ] = get_sequencer_entry_time(runNumber)
%Returns Entry time written in sequencer event elog for a given runNumber.

iMax = numel(runNumber);
time = zeros(size(runNumber));

for i=1:iMax

        dataDir='../../DataSets/RawData/seq_LR';

    %figure out html file name from runNumber
    fileNamePattern=strcat('^seq_',int2str(runNumber(i)),'_\d*.html');
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
        timePattern='SEQUENCEREVENT\s*(?<day>\d*)\.(?<month>\d*)\.(?<year>\d*)\s*:\s*(?<hour>\d*):(?<minute>\d*):(?<second>\d*)\s*;\s*';
        timeFound=false;
        fileID=fopen(fileName);
        %iterate over lines of html file
        lineText=fgetl(fileID);
        while ischar(lineText)
            if (~isempty(regexp(lineText,timePattern, 'once')))
               timeMatch=regexp(lineText,timePattern,'names');
                if timeFound>1
                    %This line appears twice, so if it's appeared twice already,
                    %there's a problem
                    dispString=strcat('Found multiple times for runNumber=',...
                                      int2str(runNumber(i)));
                    disp(dispString)
                end
                timeFound=timeFound+1;
                %disp(timeMatch)
            end
            lineText=fgetl(fileID);
        end
        fclose(fileID);

        if ~timeFound
            dispString=strcat('Failed to find time for runNumber=', ...
                              int2str(runNumber(i)));
            disp(dispString)
        end
        if  ~timeFound
            time(i)=NaN;
        else
            %Interpret regex matches to get info for datenum
            year=str2double(timeMatch.year);
            month=str2double(timeMatch.month);
            day=str2double(timeMatch.day);
            hour=str2double(timeMatch.hour);
            minute=str2double(timeMatch.minute);
            second=str2double(timeMatch.second);   
            %disp(year);disp(month);disp(day);disp(hour);disp(minute);disp(second);

            %Finally, calculate time using datenum
            time(i)=datenum(year,month,day,hour,minute,second); 
        end
    end
end