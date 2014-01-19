function [ t_z_array ] = read_data_set( file_name )
%Returns an array of event times and annihilation z-positions from data set
%   Times are recorded in the datenum() format and z-positions are recorded
%   as meters from trap center.
    t_z_array=dlmread(file_name);
end