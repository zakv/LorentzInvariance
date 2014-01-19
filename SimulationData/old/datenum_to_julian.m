function [ julian_times ] = datenum_to_julian( datenum_times )
%Converts Matlab's datenum() times to unix times.
%   Input should be array of datenum() times

    julian_times=juliandate(datestr(datenum_times));
end

