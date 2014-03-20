function tobj = event_time()

% get information of event time
%
% ex)
%   t = event_time();
%   t.run(year,RorL,mode) : Gets runNumber
%   t.utc(year,RorL,mode) : Gets Event time in UTC (Universal
%   Coordinated Time), matlab dateNumber
%   t.utc_jd(year,RorL,mode) : Gets Event time in UTC, with Julian
%   Date format
%   t.type(year,RorL,mode) : Gets type of Event time. Returns 1 for
%   time_MCP, 2 for time_CsI, 0 for entryTime(inaccurate time)
%
% year : '2011', '2010', or 'all'
% RorL : 'R', 'L', or 'all'
%        'R' for right, 'L' for left, 'all' for both right and left
% mode : '1' or '0' 
%        mode = 1 for getting accurate Event time (accurate to seconds)
%        mode = 0 for getting rough Event time (accurate to ~ 2 hours)

oldDr = cd('../../DataSets/');
data = load('EventTimeData');
failed_run_obj = load('FailedRunData.mat');
spill_log_obj = load('spillLogEntryTimeData.mat');
attempted_run_obj = load('EntryTimeWithEplusCatchData.mat');
shift_cycle_obj = load('GuessedAttemptedShiftTimeData.mat');
cd(oldDr);

shiftCycle_g = shift_cycle_obj.shiftCycle;
attemptedRun_g = attempted_run_obj.run;
attemptedDataLog_g = attempted_run_obj.dataLog;
attemptedSpillLogEntryTime_g = attempted_run_obj.spillLogEntryTime;
failedRun_g = failed_run_obj.failedRun;
failedDataLog_g = failed_run_obj.failedDataLog;
spillLogEntryTime_g = spill_log_obj.spillLogEntryTime;
spillLogRun_g = spill_log_obj.run;
spillLogDataLog_g= spill_log_obj.dataLog;

run2011R = data.run2011R;
st2011R = data.st2011R;
utc2011R = data.utc2011R;
jd2011R = data.jd2011R;
type2011R = data.type2011R;

run2010R = data.run2010R;
st2010R = data.st2010R;
utc2010R = data.utc2010R;
jd2010R = data.jd2010R;
type2010R = data.type2010R;

run2010L = data.run2010L;
st2010L = data.st2010L;
utc2010L = data.utc2010L;
jd2010L = data.jd2010L;
type2010L = data.type2010L;

run2011R_a = data.run2011R_a;
st2011R_a = data.st2011R_a;
utc2011R_a = data.utc2011R_a;
jd2011R_a = data.jd2011R_a;
type2011R_a = data.type2011R_a;

run2010R_a = data.run2010R_a;
st2010R_a = data.st2010R_a;
utc2010R_a = data.utc2010R_a;
jd2010R_a = data.jd2010R_a;
type2010R_a = data.type2010R_a;

run2010L_a = data.run2010L_a;
st2010L_a = data.st2010L_a;
utc2010L_a = data.utc2010L_a;
jd2010L_a = data.jd2010L_a;
type2010L_a = data.type2010L_a;
 
tobj = public();

    function shiftCycle = shiftCycleTimes()
        shiftCycle = shiftCycle_g;
    end

    function attemptedRun = attemptedRunNumber()
        attemptedRun = attemptedRun_g;
    end

    function attemptedDataLog = attemptedDataLogNumber()
        attemptedDataLog = attemptedDataLog_g;
    end

    function attemptedSpillLogEntryTime = attemptedSpillLogEntryTime()
        attemptedSpillLogEntryTime = attemptedSpillLogEntryTime_g;
    end

    function failedRun = failedRunNumber()
        failedRun = failedRun_g;
    end

    function failedDataLog = failedDataLogNumber()
        failedDataLog = failedDataLog_g;
    end

    function spillLogRun = spillLogRun()
        spillLogRun = spillLogRun_g;
    end

    function spillLogDataLog = spillLogDataLog()
        spillLogDataLog = spillLogDataLog_g;
    end

    function spillLogEntryLocal = spillLogEntryTime()
        spillLogEntryLocal = spillLogEntryTime_g;
    end
        
    function run = runNumber(year,RorL,mode)

        if mode == 1
            if strcmp(year,'2010') == 1 &&  strcmp(RorL,'L') == 1
                run = run2010L_a;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'R') == 1
                run = run2010R_a;
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'R') == 1
                run = run2011R_a;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'R') == 1
                run = vertcat(run2011R_a, run2010R_a);
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'L') == 1
                run = run2010L_a;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
                run = vertcat(run2010R_a,run2010L_a);
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
                run = run2011R_a;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
                run = vertcat(run2011R_a,run2010R_a, run2010L_a);
            else
                disp('ERROR mistyped year or RorL');
            end
        elseif mode == 0
            if strcmp(year,'2010') == 1 &&  strcmp(RorL,'L') == 1
                run = run2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'R') == 1
                run = run2010R;
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'R') == 1
                run = run2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'R') == 1
                run = vertcat(run2011R, run2010R);
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'L') == 1
                run = run2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
                run = vertcat(run2010R,run2010L);
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
                run = run2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
                run = vertcat(run2011R,run2010R, run2010L);
            else
                disp('ERROR mistyped year or RorL');
            end
        else
            disp('ERROR mistyped mode');
        end
    end

    function utc = utc(year,RorL,mode)
        if mode == 1
            if strcmp(year,'2010') == 1 &&  strcmp(RorL,'L') == 1
                utc = utc2010L_a;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'R') == 1
                utc = utc2010R_a;
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'R') == 1
                utc = utc2011R_a;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'R') == 1
                utc = vertcat(utc2011R_a, utc2010R_a);
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'L') == 1
                utc = utc2010L_a;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
                utc = vertcat(utc2010R_a,utc2010L_a);
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
                utc = utc2011R_a;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
                utc = vertcat(utc2011R_a,utc2010R_a, utc2010L_a);
            else
                disp('ERROR mistyped year or RorL');
            end
        elseif mode == 0
            if strcmp(year,'2010') == 1 &&  strcmp(RorL,'L') == 1
                utc = utc2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'R') == 1
                utc = utc2010R;
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'R') == 1
                utc = utc2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'R') == 1
                utc = vertcat(utc2011R, utc2010R);
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'L') == 1
                utc = utc2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
                utc = vertcat(utc2010R,utc2010L);
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
                utc = utc2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
                utc = vertcat(utc2011R,utc2010R, utc2010L);
            else
                disp('ERROR mistyped year or RorL');
            end
        else
            disp('ERROR mistyped mode');
        end
    end

    function st = local(year,RorL,mode)
        if mode == 1
            if strcmp(year,'2010') == 1 &&  strcmp(RorL,'L') == 1
                st = st2010L_a;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'R') == 1
                st = st2010R_a;
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'R') == 1
                st = st2011R_a;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'R') == 1
                st = vertcat(st2011R_a, st2010R_a);
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'L') == 1
                st = st2010L_a;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
                st = vertcat(st2010R_a,st2010L_a);
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
                st = st2011R_a;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
                st = vertcat(st2011R_a,st2010R_a, st2010L_a);
            else
                disp('ERROR mistyped year or RorL');
            end
        elseif mode == 0
            if strcmp(year,'2010') == 1 &&  strcmp(RorL,'L') == 1
                st = st2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'R') == 1
                st = st2010R;
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'R') == 1
                st = st2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'R') == 1
                st = vertcat(st2011R, st2010R);
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'L') == 1
                st = st2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
                st = vertcat(st2010R,st2010L);
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
                st = st2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
                st = vertcat(st2011R,st2010R, st2010L);
            else
                disp('ERROR mistyped year or RorL');
            end
        else
            disp('ERROR mistyped mode');
        end
    end

    function utc_jd = utc_jd(year,RorL,mode)
        if mode == 1
            if strcmp(year,'2010') == 1 &&  strcmp(RorL,'L') == 1
                utc_jd = jd2010L_a;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'R') == 1
                utc_jd = jd2010R_a;
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'R') == 1
                utc_jd = jd2011R_a;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'R') == 1
                utc_jd = vertcat(jd2011R_a, jd2010R_a);
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'L') == 1
                utc_jd = jd2010L_a;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
                utc_jd = vertcat(jd2010R_a,jd2010L_a);
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
                utc_jd = jd2011R_a;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
                utc_jd = vertcat(jd2011R_a,jd2010R_a, jd2010L_a);
            else
                disp('ERROR mistyped year or RorL');
            end
        elseif mode == 0
            if strcmp(year,'2010') == 1 &&  strcmp(RorL,'L') == 1
                utc_jd = jd2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'R') == 1
                utc_jd = jd2010R;
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'R') == 1
                utc_jd = jd2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'R') == 1
                utc_jd = vertcat(jd2011R, jd2010R);
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'L') == 1
                utc_jd = jd2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
                utc_jd = vertcat(jd2010R,jd2010L);
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
                utc_jd = jd2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
                utc_jd = vertcat(jd2011R,jd2010R, jd2010L);
            else
                disp('ERROR mistyped year or RorL');
            end
        else
            disp('ERROR mistyped mode');
        end
    end

function type = type(year,RorL,mode)
        if mode == 1
            if strcmp(year,'2010') == 1 &&  strcmp(RorL,'L') == 1
                type = type2010L_a;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'R') == 1
                type = type2010R_a;
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'R') == 1
                type = type2011R_a;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'R') == 1
                type = vertcat(type2011R_a, type2010R_a);
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'L') == 1
                type = type2010L_a;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
                type = vertcat(type2010R_a,type2010L_a);
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
                type = type2011R_a;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
                type = vertcat(type2011R_a,type2010R_a, type2010L_a);
            else
                disp('ERROR mistyped year or RorL');
            end
        elseif mode == 0
            if strcmp(year,'2010') == 1 &&  strcmp(RorL,'L') == 1
                type = type2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'R') == 1
                type = type2010R;
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'R') == 1
                type = type2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'R') == 1
                type = vertcat(type2011R, type2010R);
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'L') == 1
                type = type2010L;
            elseif strcmp(year,'2010') == 1 && strcmp(RorL,'all') == 1
                type = vertcat(type2010R,type2010L);
            elseif strcmp(year,'2011') == 1 && strcmp(RorL,'all') == 1
                type = type2011R;
            elseif strcmp(year,'all') == 1 && strcmp(RorL,'all') == 1
                type = vertcat(type2011R,type2010R, type2010L);
            else
                disp('ERROR mistyped year or RorL');
            end
        else
            disp('ERROR mistyped mode');
        end
    end

    function o = public()
        o = struct(...
            'shiftCycle', @shiftCycleTimes,...
            'attemptedRun', @attemptedRunNumber,...
            'attemptedDataLog', @attemptedDataLogNumber,...
            'attemptedSpillLogEntryTime', @attemptedSpillLogEntryTime,...
            'spillLogRun', @spillLogRun,...
            'spillLogDataLog', @spillLogDataLog,...
            'spillLogEntryLocal', @spillLogEntryTime,...
            'failedRun', @failedRunNumber,...
            'failedDataLog', @failedDataLogNumber,...
            'utc', @utc,...
            'run', @runNumber,...
            'utc_jd', @utc_jd,...
            'local', @local,...
            'type', @type);
    end
        
end