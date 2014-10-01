function [ event_times,n_left ] = generate_event_times(random_generator) %#ok<INUSD>
%Returns a column vector of the actual event times in Geneva time.  This
%function caches the data that it reads from the hard drive, so if for some
%reason you update the .mat file with the annihilation times in this
%directory, run "clear all" or restart matlab in order to clear the cache.
%Also returns the number of quip left data points as n_left (which are the
%last n_left entries in the event_times vector).

persistent pers_event_times
persistent pers_n_left
if isempty(pers_event_times)
    %Load data from this file's directory
    file_name='eventTime_experiment.mat';
    data_path=fileparts(which(mfilename));
    file_path=fullfile(data_path,file_name);
    hard_drive_data=load(file_path);
    quip_right=hard_drive_data.eventTime_local_r;
    quip_left=hard_drive_data.eventTime_local_l;
    pers_n_left=length(quip_left);
    pers_event_times=[quip_right;quip_left];
end

event_times=pers_event_times;
n_left=pers_n_left;

end