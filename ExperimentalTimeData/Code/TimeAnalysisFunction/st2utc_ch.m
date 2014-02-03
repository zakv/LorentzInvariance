function  UTC = st2utc_ch(swissTime)
% Converts Swiss(ch) time to Coordinated Universal Time(UTC) considering daylight
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