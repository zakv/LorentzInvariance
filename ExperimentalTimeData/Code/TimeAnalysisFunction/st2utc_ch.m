function  UTC = st2utc_ch(swissTime)
% Converts Swiss(ch) standard time to Coordinated Universal Time(UTC) considering daylight
% saving
%   This version works on arrays of arbitrary size/dimension.

iMax=numel(swissTime);
UTC=zeros(size(swissTime));

for i=1:iMax
    checkDST = check_swiss_dst(swissTime(i));
    if checkDST == 0
        UTC(i) = swissTime(i) - (1/24.);
    elseif checkDST == 1
        UTC(i) = swissTime(i) - (2/24.);
    else
        UTC(i) = NaN;
    end
end

end

function check = check_swiss_dst(swissTime)
%Check whether the clock time is DST - Daylight Saving Time (UTC+2)
%or not(UTC+1). Returns 1 for summer time(DST), 0 for winter time.
%   Calls to datenum() are slow, so the calls to datenum() have been
%   replaced with their output, which is the same for all calls to this
%   function (gives ~170 times speed).


%DST, these are the dates/times corresponding to the values in swissDST
% swissDST = [datenum(2009,3,29,2,0,0) , datenum(2009,10,25,2,0,0);...
%           datenum(2010,3,28,2,0,0) , datenum(2010,10,31,2,0,0);...
%           datenum(2011,3,27,2,0,0) , datenum(2011,10,30,2,0,0);...
%           datenum(2012,3,25,2,0,0) , datenum(2012,10,28,2,0,0);...
%           datenum(2013,3,31,2,0,0) , datenum(2013,10,27,2,0,0);...
%           datenum(2014,3,30,2,0,0) , datenum(2014,10,26,2,0,0);...
%           datenum(2015,3,29,2,0,0) , datenum(2015,10,25,2,0,0);...
%           datenum(2016,3,27,2,0,0) , datenum(2016,10,30,2,0,0);...
%           datenum(2017,3,26,2,0,0) , datenum(2017,10,29,2,0,0);...
%           datenum(2018,3,25,2,0,0) , datenum(2018,10,28,2,0,0);...
%           datenum(2019,3,31,2,0,0) , datenum(2019,10,27,2,0,0)];

swissDST =[7.338610833333334,   7.340710833333334;...
           7.342250833333334,   7.344420833333333;...
           7.345890833333334,   7.348060833333334;...
           7.349530833333334,   7.351700833333334;...
           7.353240833333333,   7.355340833333334;...
           7.356880833333333,   7.358980833333334;...
           7.360520833333334,   7.362620833333334;...
           7.364160833333334,   7.366330833333333;...
           7.367800833333334,   7.369970833333333;...
           7.371440833333334,   7.373610833333334;...
           7.375150833333334,   7.377250833333334];
       
swissDST=1.0e5*swissDST;

iMax = numel(swissTime);
check = zeros(size(swissTime));

for i = 1:iMax
    if swissTime(i) < 733774 %datenum(2009,1,1,0,0,0)
        disp('ERROR cannot calculate time before 2009');
        check(i) = NaN;
    elseif 737791 <= swissTime(i) %datenum(2020,1,1,0,0,0)
        disp('ERROR cannot calculate time after 2019');
        check(i) = NaN;
    else
        jMax = length(swissDST);
        for j = 1:jMax
            if swissDST(j,1) < swissTime(i) && swissTime(i) < swissDST(j,2)
                check(i) = 1;
            elseif swissDST(j,2) <= swissTime(i) && swissTime(i) <= ( swissDST(j,2)+1/24. )
                dispString = strcat('WARNING two possible times because of daylight saving at ',datestr(swissTime(i)));
                disp(dispString);
                check(i) = NaN;
            end
        end
    end
end                  
                          
end             