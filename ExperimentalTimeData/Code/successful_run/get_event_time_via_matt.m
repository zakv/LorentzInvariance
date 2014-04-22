function [ time ] = get_event_time_via_matt(runNumber)
%Returns event time for a given runNumber. Looks for excel files in the
%same directory.

oldDir = cd('../../DataSets/RawData/eventTimeData');
obj = load('EventTimeData_2010_matt');
st2010_matt = obj.st2010_matt;
cd(oldDir);

oldDir = cd('../../Class/');
successful = successful_run();
run2010 = successful.run('local','2010','all');
cd(oldDir);
run2010 = sort(run2010);

iMax = numel(runNumber);
time = zeros(size(runNumber));

for i = 1:iMax
    time(i) = st2010_matt(run2010==runNumber(i));
    if isempty(time(i))
        time(i) = NaN;
    end
end