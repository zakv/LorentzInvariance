clear all;

AttemptedRunInterval = calc_attempted_run_interval();
oldDir = cd('../../DataSets');
save('AttemptedRunInterval12hData.mat','AttemptedRunInterval');
cd(oldDir);