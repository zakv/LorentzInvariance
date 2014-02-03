function [ time ] = get_event_time_via_matt(runNumber)
%Returns event time for a given runNumber. Looks for excel files in the
%same directory.

t = event_time();
oldDir = cd('../../DataSets/');
load('EventTimeData_2010_matt');
cd(oldDir);

iMax = numel(runNumber);
time = zeros(size(runNumber));
run2010 = t.run('2010','all',0);
st2010_matt = vertcat(st2010R_matt, st2010L_matt); %want to fix
jMax = numel(run2010);
check = zeros(size(runNumber));

for i = 1:iMax
    for j = 1:jMax
        if runNumber(i) == run2010(j)
            time(i) = st2010_matt(j);
            check(i) = 1;
            break
        end
    end
    if check(i) == 0
        disp('ERROR : only 2010 run data available');
        time = NaN;
        break
    end
end