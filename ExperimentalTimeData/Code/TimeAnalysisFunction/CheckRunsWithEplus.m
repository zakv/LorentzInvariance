%Checks if all successful events are included in spillLog run with initial
%e+ catch

clear all;

t = event_time();
successfulRuns = t.run('all','all',0);
runsWithEplus = t.spillLogRun();
time = t.local('all','all',0);

iMax = numel(successfulRuns);
jMax = numel(runsWithEplus);
check = zeros(jMax,1);

for i = 1:iMax
    for j = 1:jMax
        if runsWithEplus(j) == successfulRuns(i)
            check(i) = 1;
            break
        end
    end
    if check(i) == 0
        dispstr = ['Cannot find run=',num2str(successfulRuns(i)),...
            ', ',datestr(time(i))];
            disp(dispstr)
    end
end
            