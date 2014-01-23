function [ speed,theta,phi ] = datenum_to_cmb_velocity( datenum_times )
%Returns three arrays: the first giving the CMB speed of the experiment,
%the second giving the angle (theta, in degrees) of the trap relative to
%the CMB velocity vector, and the third giving one last mostly irrelevant
%position angle.
%   The last angle (phi, in degrees) the rotation around the trap axis of
%   the CMB velocity vector.  phi=0 corresponds to the CMB velocity vector
%   pointing in the plane defined by a vector pointing to the zenith and
%   one pointing along the trap axis.

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
    
    %Use aephem to calculate Earth's velocity
    [speed,theta,phi]=cmb_velocity(unix_times); %gets three components
end

