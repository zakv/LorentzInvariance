function [ v_x,v_y,v_z ] = datenum_to_cmb_velocity( datenum_times )
%Returns three arrays, each with giving one component of the velocity (in
%m/s in cartesian J2000 coordinates) at the corresponding time (given in
%datenum() format).
%   Input times should be given in datenum() format in the Geneva time zone
%   with Daylight Savings effects removed. Each array returned is of the
%   same size/dimensions as the input. The first array corresponds to the
%   first components of the velocity vectors at the given time, and same
%   the same sort of thing for the second and third arrays.

    %Load aephem libraries if not already loaded
    if ~libisloaded('libaephem')
        %Suppress warnings that don't seem to matter
        warning off MATLAB:loadlibrary:TypeNotFound;
        warning off MATLAB:loadlibrary:TypeNotFoundForStructure;
        warning off MATLAB:loadlibrary:FunctionNotFound;
        warning off MATLAB:loadlibrary:parsewarnings;
        %Load the aephem library (must be loaded to run the mex functions)
        loadlibrary('../../aephem-2.0.0/src/.libs/libaephem.so','../../aephem-2.0.0/src/aephem.h');
        %Enable warnings in case other code raises them in the future
        warning on MATLAB:loadlibrary:TypeNotFound;
        warning on MATLAB:loadlibrary:TypeNotFoundForStructure;
        warning on MATLAB:loadlibrary:FunctionNotFound;
        warning on MATLAB:loadlibrary:parsewarnings;
    end
    
    %Convert times to Unix time
    unix_times=datenum_to_unix_time(datenum_times);
    
    %Use aephem to calculate Earth's velocity
    [v_x,v_y,v_z]=cmb_velocity(unix_times); %gets three components
end

