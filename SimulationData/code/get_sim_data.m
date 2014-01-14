function [ sim_data ] = get_sim_data( file_name )
%Returns array of data with simulation times and z positions of
%annihilations in file with name fileName
%   Times returned are not wall times.  They are the times between the
%   quench and the Hbar annihilation.  Each row of simData is a pair of 
%   t_sim and z values corresponding to one simulated annihilation.
    sim_data=dlmread(file_name);
end