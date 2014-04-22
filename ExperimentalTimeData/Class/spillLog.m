function tobj = spillLog()

% get information of spillLog
%
% ex)
%   spillLog = event_time();
%   spillLog.run() : Gets runNumber
%   spillLog.ID() : Gets data log of spill log
%   spillLog.entryTime() :


oldDir = cd('../DataSets/');
data_obj = load('spillLogData');
cd(oldDir);

run_g = data_obj.run;
ID_g = data_obj.ID;
entryTime_g = data_obj.entryTime;

 
tobj = public();

    function run = run()
        run = run_g;
    end

    function ID = ID()
        ID = ID_g;
    end

    function entryTime = entryTime()
        entryTime = entryTime_g;
    end

    function o = public()
        o = struct(...
            'run', @run,...
            'ID', @ID,...
            'entryTime', @entryTime);
    end     
end