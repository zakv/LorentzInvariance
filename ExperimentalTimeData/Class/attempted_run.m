function tobj = attempted_run()

%ex)
%   attempted = ettempted_run();
%   attempted.run
%   attempted.dataLog
%   attempted.endTime
%   attempted.startTime
%   attempted.runTime

oldDr = cd('../DataSets/');
data_obj = load('attemptedRunData');
cd(oldDr);

%run data which was attempted or trapped
run_g = data_obj.run;
dataLog_g = data_obj.dataLog;
spillLog_g = data_obj.spillLogID;
startTime_g = data_obj.startTime;
endTime_g = data_obj.endTime;

% run data which also has quench dump activity
run_quench_g = data_obj.run_quench;
dataLog_quench_g = data_obj.dataLog_quench;
spillLog_quench_g = data_obj.spillLogID_quench;
start2end_quench_g = data_obj.start2end_quench;

tobj = public();

    function run = run()
        run = run_g;
    end

    function dataLog = dataLog()
        dataLog = dataLog_g;
    end

    function spillLog = spillLog()
        spillLog = spillLog_g;
    end

    function startTime = startTime()
        startTime = startTime_g;
    end

    function endTime = endTime()
        endTime = endTime_g;
    end

    function run_quench = run_quench()
        run_quench = run_quench_g;
    end

    function dataLog_quench = dataLog_quench()
        dataLog_quench = dataLog_quench_g;
    end

    function spillLog_quench = spillLog_quench()
        spillLog_quench = spillLog_quench_g;
    end

    function start2end_quench = start2end_quench()
        start2end_quench = start2end_quench_g;
    end

    function o = public()
        o = struct(...
            'run', @run,...
            'dataLogID', @dataLog,...
            'spillLogID', @spillLog,...
            'startTime', @startTime,...
            'endTime', @endTime,...
            'run_quench', @run_quench,...
            'dataLogID_quench', @dataLog_quench,...
            'spillLogID_quench', @spillLog_quench,...
            'start2end_quench', @start2end_quench);
    end
end