function [ event_times,n_left ] = generate_event_times(random_generator) %#ok<INUSD>
%Need to update n_left at end.
%Need to make sure the timezone from the data file is correct.
%Need to make sure the data file has already accounted for daylight savings
%time

%Returns a column vector of the actual event times in Geneva time.  This
%function caches the data that it reads from the hard drive, so if for some
%reason you update the .mat file with the annihilation times in this
%directory, run "clear all" or restart matlab in order to clear the cache.

persistent local_time_data
if isempty(local_time_data)
    %Load data from this file's directory
    file_name='eventTime_experiment.mat';
    data_path=fileparts(which(mfilename));
    file_path=fullfile(data_path,file_name);
    hard_drive_data=load(file_path);
    local_time_data=hard_drive_data.eventTime_local;
end

event_times=local_time_data;
n_left=0;

end