function time = m2xdate_safe(MtTime)
% This is the improved virsion of Matlab function 'm2xdate', which converts
% matlab date number to excel date number.
%   Reterns NaN when MtTime is NaN (instead of showing error).

iMax = numel(MtTime);
time = zeros(size(MtTime));
for i = 1:iMax;
    if ~isnan(MtTime(i))
        time(i) = m2xdate(MtTime(i),0);
    else
        time(i) = NaN;
    end
end
end
