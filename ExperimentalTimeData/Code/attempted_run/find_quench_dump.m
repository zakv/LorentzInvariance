function [quenchFound] = find_quench_dump(logID,run,IDType)
%search is there is quench dump activitiy in the record(either elog data or
%spill log)
%IDType = 'elogData', 'elogData_all', or 'SpillLog'
%return 0 or 1(found)
%look for timeline of the given run in case different run's timeline is
%attached because sometimes different run's timeline is attached!

iMax = numel(logID);
quenchFound = zeros(iMax,1);

for i = 1:iMax
    
    dataDir1 = '../../DataSets/RawData/elogData';
    dataDir2='../../DataSets/RawData/elogData_all';
    dataDir3='../../DataSets/RawData/SpillLog';
    fileNamePattern1=strcat('(^run\d*_|^\d*_)',int2str(logID(i)),'.html');
    fileNamePattern2=strcat('^',int2str(logID(i)),'.html');

    %figure out html file name from logID
    fileNameFound=false;
    if strcmp(IDType,'elog') ==1 || strcmp(IDType,'dataLog') == 1
        fileNamePattern = fileNamePattern1;
        dataDir = dataDir1;
    elseif strcmp(IDType,'elogData_all') == 1 || strcmp(IDType,'dataLog_all') == 1
        fileNamePattern = fileNamePattern2;
        dataDir = dataDir2;
    elseif strcmp(IDType,'spillLog') == 1
        fileNamePattern = fileNamePattern2;
        dataDir = dataDir3;
    else
        disp('wrong imput for IDType');
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
        dispString=['Failed to find file for ',IDType,'=', ...
                              int2str(logID(i))];
                          disp(dispString);
                          quenchFound(i)=NaN;
    else
        %getexp
        quenchPattern='\s*\|\s*Quench\s*dump\s*\[[\d.]*\-[\d.]*\]=';
        quenchFound(i)=0;
        runPattern=['^Run\s',num2str(run(i)),'$'];
        runFound=false;
        
        fileID=fopen(fileName);
        %iterate over lines of html file
        lineText=fgetl(fileID);
        while ischar(lineText) && ~quenchFound(i)
            if ~isempty(regexp(lineText,runPattern,'once'))
                runFound=1;
            elseif ~isempty(regexp(lineText,quenchPattern, 'once')) && ~quenchFound(i) && runFound
                quenchFound(i)=true;
            end
            lineText=fgetl(fileID);
        end
        fclose(fileID);
        if ~runFound
            dispString = ['Failed to find the spill timeline for ',IDType,'=',...
                int2str(logID(i))];
            disp(dispString)
        elseif ~quenchFound(i)
            dispString=['Failed to find quench for ',IDType,'=', ...
                int2str(logID(i))];
            disp(dispString)
        end
    end
end
end
        

            
        