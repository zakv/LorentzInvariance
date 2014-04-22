function tobj = shift_cycle()

% get information of spillLog
%
% ex)
%   shift_cycle = shift_cycle();
%   shift_cycle.successful() : Gets shift cycle with attempted run
%   shift_cycle.attempted() : Gets shift cycle with successful run


oldDir = cd('../DataSets/');
data_obj = load('shiftTimeData');
cd(oldDir);

successful_g = data_obj.successfulShiftCycle;
attempted_g = data_obj.attemptedShiftCycle;

 
tobj = public();

    function successful = successfulCycle()
        successful = successful_g;
    end

    function attempted = attemptedCycle()
        attempted = attempted_g;
    end

    function o = public()
        o = struct(...
            'successful', @successfulCycle,...
            'attempted', @attemptedCycle);
    end     
end