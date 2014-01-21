function [ altitude,azimuth,distance ] = datenum_to_sun_position( datenum_times )
%Returns three arrays containing (1) altitude, (2) azimuth, and (3)
%distance of the sun (in AU) at the corresponding times (given in datenum()
%format).
%   Input times should be given in datenum() format in the Geneva time zone
%   with Daylight Savings effects removed. Each array returned is of the
%   same size/dimensions as the input.

    %Load aephem libraries if not already loaded
    if ~libisloaded('libaephem')
        %Suppress warnings that don't seem to matter
        warning off MATLAB:loadlibrary:TypeNotFound;
        warning off MATLAB:loadlibrary:TypeNotFoundForStructure;
        warning off MATLAB:loadlibrary:FunctionNotFound;
        warning off MATLAB:loadlibrary:parsewarnings;
        %Load the aephem library (must be loaded to run the mex functions)
        loadlibrary('../../../aephem-2.0.0/src/.libs/libaephem.so','../../../aephem-2.0.0/src/aephem.h');
        %Enable warnings in case other code raises them in the future
        warning on MATLAB:loadlibrary:TypeNotFound;
        warning on MATLAB:loadlibrary:TypeNotFoundForStructure;
        warning on MATLAB:loadlibrary:FunctionNotFound;
        warning on MATLAB:loadlibrary:parsewarnings;
    end
    
    %Convert times to Unix time
    unix_times=datenum_to_unix_time(datenum_times);
    
    %Use aephem to calculate sun's position
    [altitude,azimuth,distance]=sun_position(unix_times); %gets three components
end
