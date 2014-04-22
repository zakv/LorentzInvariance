function [run] = get_attempted_run(dataLogNumber)

%Returns run number for a given dataLog if the subject is 'Trapping' or 'attempt'.
%   Looks for files in dataDir,set early in this function.
%   Gets "run number"

iMax = numel(dataLogNumber);
run = NaN(size(dataLogNumber));

for i = 1:iMax
    
    dataDir='../../DataSets/RawData/elogData_all';
    
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
                          run(i)=NaN;
    else
        %regex the necessary stuff
        runPattern='<input\s*type=hidden\s*name="Run"\s*value="(?<run>\d*)">$';
        runFound=false;
        subjectPattern='<input\s*type=hidden\s*name="Subject"\s*value="(\s|\S)*(?<attempt>Trapping|attempt|Attempt)';
        subjectFound=false;
        fileID=fopen(fileName);
        %iterate over lines of html file
        lineText=fgetl(fileID);
        while ischar(lineText)
            if ~isempty(regexp(lineText,runPattern,'once'))
                runMatch=regexp(lineText,runPattern,'names','once');
                runFound=1;
            elseif ~isempty(regexp(lineText,subjectPattern,'once')) && runFound
                subjectMatch=regexp(lineText,subjectPattern,'names','once');
                subjectFound=1;
            end
            lineText=fgetl(fileID);
        end
        fclose(fileID);
        if ~runFound
            dispString=strcat('Failed to find run number for dataLogNumber=',...
                int2str(dataLogNumber(i)));
            disp(dispString);
        end
        if subjectFound
            dispString = strcat('"',subjectMatch.attempt,'" found for dataLogNumber=',...
                int2str(dataLogNumber(i)));
            disp(dispString)
        end
        if subjectFound && runFound
            %Interpret regex matches to get info for datenum
            run(i)=str2double(runMatch.run);
        end
    end
end

end