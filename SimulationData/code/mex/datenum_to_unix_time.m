function [ unix_times ] = datenum_to_unix_time( datenum_times )
%Takes times given datenum() format in the Geneva time zone (with Daylight
%Savings effects already removed) and returns the Unix time
%   This previously used Fumika's code and takes care of daylight savings
%   time, but this feature was removed because (1) it added confusion about
%   times that occur twice due to moving back an hour and (2) some
%   performance loss due to extra computation.

    %Constants
    UNIX_ZERO=719529; %datenum(1970,1,1,0,0,0) = datenum at which unix time is zero
    SECONDS_PER_DAY=60*60*24; %number of seconds in Matlab day    
    
    %convert to GMT/UTC then to Unix time, (aephem code will convert this
    %to julian in TT).
    %addpath ../../EventTime;
    %UTC_times=st2utc_CH_fast(datenum_times);
    UTC_times=datenum_times-1/24.0; %Subtract 1 hour to get UTC
    unix_times=(UTC_times-UNIX_ZERO)*SECONDS_PER_DAY;
end

