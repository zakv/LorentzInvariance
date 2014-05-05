%Generate attempted run number, the time when run starts and ends, and the
%time between them.
%Look for both elog and spill log html files.
%elog data - ID is "dataLog"
%spill log data - ID is "spillLogID"
%
%1) Gets a run number which is attempted to trap hbar.
%2) Gets startTime and endTime of each run.
%3) Sort the run which has quench dump activity, and get time between
%startTime and endTime (start2end_quench).

%endTime : entry time of spill log data. The entry time of elog is useless
%(the time is recorded manually).
%startTime : the first time that appears to either elog or spill log,
%because sometimes elog has timeline while spill log doesn't (or less), so
%does to the opposite situation.
%start2end : time bitween startTime and endTime. Calculated only when there
%is quench dump activity.

%runs failed to find startTime
%run   dataLogID
%22028 20404 - aborted
%22363 20985 - seems like testing (spillLog empty data)
%22937 22225or22226 - beam disappeared :-(
%23073 22433 - noPbar, no spillLog, out of shift (means testing, i guess)
%25191 25299 - no spilllog (how come...)
%26060 26509 -  AlphaEvents gave nonsense again... And no spillLog either.
%28297 28850 - uwave off, no beam abort, no spillLog
%29260 30017 - low hot dump, no spill log..

%need to exclude run 27096! (datalog:27530,spilllog:15303)
% It says "attempt" in Subject, but obviously not a trapping attempt. It is
% RA test.

%------get attempted run number & dataLog---------------------------------
%get attempted run number
dataLog = (19195:1:30154);
run = get_attempted_run(dataLog);
%exclude nul runs (not an attempted run) and dataLog
index_noAttempt = isnan(run);
run(index_noAttempt)=[];
dataLog(index_noAttempt)=[];

%----get spillLogID&startTime of the attempted run -----------------------
%get all runs and all spillLogID data
oldDir = cd('../../Class/');
spillLog = spillLog();
spillLogID_all = spillLog.ID();
run_all = spillLog.run();
entryTime_all = spillLog.entryTime();
cd(oldDir);

iMax = numel(run);
spillLogID = nan(iMax,1);
startTime = nan(iMax,1);
endTime = nan(iMax,1);
run_notFound = zeros(iMax,1);

for i = 1:iMax
    %-----check if we got startTime at last run-----
    if i >= 2
        %already found out the startTime for the run
        if run(i) == run(i-1) && found
            continue
        end
        if run(i) > run(i-1)
            %could not find the startTime for the prior run number
            if ~found
                dispstr = ['Failed to find starting time for run=',...
                    num2str(run(i-1)),'(ID:',num2str(dataLog(i-1)),')'];
                disp(dispstr);
                run_notFound(i) = run(i);
            end
        end
    end
    
    %----look for startTime (and endTime)------------
    found = 0;
    %look at spillLog
    index = find(run_all == run(i));
    if ~isempty(index)
        %in case there are multiple spillLog for the run
        index_row = 1;
        startTime_spill = NaN;
        while isnan(startTime(i)) && index_row <= numel(index)
            spillLogID(i) = spillLogID_all(index(index_row));
            [endTime(i),startTime(i)] = get_entryTime_startTime(spillLogID(i),run(i),'spillLog');          
            index_row = index_row + 1;
        end
        if ~isnan(dataLog(i))
            [~,startTime_elog] = get_entryTime_startTime(dataLog(i),run(i),'elogData_all');
        end
        %gets the smaller startTime of elog and spillLog
        if startTime_elog < startTime(i)
            startTime(i) = startTime_elog;
        end
    end
    if isnan(spillLogID(i))
        dispstr = ['Failed to find spill log for run=',num2str(run(i))];
        disp(dispstr);
    end
    %if startTime is still not found, look at elog
    if isnan(startTime(i)) && ~isnan(dataLog(i))
        [~,startTime(i)] = get_entryTime_startTime(dataLog(i),run(i),'elogData_all');
    end
    %found startTime!
    if ~isnan(startTime(i))
        found = 1;
    end
end
%exclude the run with no startTime
index_nul = isnan(startTime);
run(index_nul) = [];
startTime(index_nul) = [];
endTime(index_nul) = [];
dataLog(index_nul) = [];
spillLogID(index_nul) = [];

%exclude data of run 27096
index_test = find(run==27096);
if ~isempty(index_test)
    run(index_test)=[];
    startTime(index_test)=[];
    endTime(index_test)=[];
    dataLog(index_test)=[];
    spillLogID(index_test)=[];
end

%---------get endTime of the run with quench dump event-------------------
%if not found quench dump at elog or spill log
index_quench = zeros(numel(run),1);
for m = 1:numel(run)
    index_quench(m) = find_quench_dump(dataLog(m),run(m),'elogData_all');
    if index_quench(m) == 0
        index_quench(m) = find_quench_dump(spillLogID(m),run(m),'spillLog');
    end
end
        
%exclude the row with no quench time and no endTime
index_quench = (index_quench)&(~isnan(endTime));
run_quench = run(index_quench==1);
dataLog_quench = dataLog(index_quench==1);
startTime_quench = startTime(index_quench==1);
spillLogID_quench = spillLogID(index_quench==1);
endTime_quench = endTime(index_quench==1);

%calculate the time between when run starts to quench occers (need to
%consider daylight saving)
oldDir = cd('../TimeAnalysisFunction/');
startTime_quench_utc = st2utc_ch(startTime_quench);
endTime_quench_utc = st2utc_ch(endTime_quench);
start2end_quench = endTime_quench_utc - startTime_quench_utc;
cd(oldDir);

%in case entry time is before start Time...
if ~isempty(find(start2end_quench < 0,1))
    disp('starting Time is after entry time for run=');
    disp(run_quench(start2end_quench < 0));
    %start2end_quench(start2end_quench < 0) = 0;
end

%save
oldDir = cd('../../DataSets/');
save('attemptedRunData','run','dataLog','startTime','endTime','spillLogID',...
    'run_quench','dataLog_quench','spillLogID_quench','startTime_quench',...
    'endTime_quench','start2end_quench');
cd(oldDir);

