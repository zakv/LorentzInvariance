%--------data---------------%
%calling functions
oldDir = cd('../../Class/');
attempted = attempted_run();
successful = successful_run();
shift = shift_cycle();
cd(oldDir);

addpath ../../Code/PlotFunction/
addpath ../../Code/TimeAnalysisFunction/

%getting data
eventTime = successful.eventTime('local','all','all');
successfulRun = successful.run('all','all');
shiftCycle = shift.attempted();
attemptedStartTime = attempted.startTime();
attemptedRun = attempted.run();

[~,operationCycle] = calc_events_per_time_cycle(attemptedStartTime,shiftCycle);

iMax = numel(eventTime);
successfulStartTime = zeros(iMax,1);
for i = 1:iMax
    successfulStartTime(i) = min(attemptedStartTime(attemptedRun==successfulRun(i)));
end

runCycle = [successfulStartTime,eventTime];
%change from local time to utc
shiftCycle = st2utc_ch(shiftCycle);
operationCycle = st2utc_ch(operationCycle);
runCycle = st2utc_ch(runCycle);

%---------plotting time event-------%
figure
plot_time_date(eventTime,'r');
set_for_time_graph();

%------patching cycle--------------%
figure
patch_timeCycle_date(shiftCycle,'w');
set_for_time_graph();
patch_timeCycle_date(operationCycle,'y');
patch_timeCycle_date(runCycle,'r');

