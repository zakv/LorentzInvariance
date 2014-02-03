function [X,Y,C] = patch_time_cycle(startTime,endTime)
%calculate X, Y of XY graph and color C matrix required for 'patch'
%function.

iMax = numel(startTime);

[~, ~, ~, sH, sMN, sS] = datevec(startTime);
startClockTime = sH + sMN./60 + sS./3600.;
[~, ~, ~, eH, eMN, eS] = datevec(endTime);
endClockTime = eH + eMN./60 + eS./3600.;

X = zeros(size(4,iMax*2));
Y = zeros(size(4,iMax*2));
C = zeros(size(4,iMax*2));
j = 0;
for i = 1:iMax
    j = j + 1;
    X(1,j) = floor(startTime(i));
    X(2,j) = X(1,j) + 1;
    Y(1,j) = startClockTime(i);
    Y(2,j) = Y(1,j);
    X(3,j) = X(2,j);
    X(4,j) = X(1,j);
    Y(3,j) = endClockTime(i);
    Y(4,j) = Y(3,j);
    if 22.999 < Y(1,j) && Y(1,j) <24.001
        X(:,j) = X(:,j) + 1;
        Y(1,j) = Y(1,j) - 24;
        Y(2,j) = Y(2,j) - 24;
    elseif startTime(i) < (floor(startTime(i)) + 23.001/24) && (floor(startTime(i)) + 23.001/24) < endTime(i)  
        Y(3,j) = 23;
        Y(4,j) = 23;
        j = j + 1;
        X(1,j) = X(1,j-1) + 1;
        X(2,j) = X(2,j-1) + 1;
        Y(1,j) = -1;
        Y(2,j) = -1;
        X(3,j) = X(2,j);
        X(4,j) = X(1,j);
        Y(3,j) = endClockTime(i);
        Y(4,j) = Y(3,j);
        if 22.999 < Y(3,j) && Y(3,j) < 24.001
            Y(3,j) = Y(3,j) - 24;
            Y(4,j) = Y(3,j);
        end
    end
end
X(:,j+1:iMax) = [];
Y(:,j+1:iMax) = [];
C(:,j+1:iMax) = [];

p = patch(X,Y,C);
set(p,'FaceColor','y')
