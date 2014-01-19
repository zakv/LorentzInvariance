sim_data=get_sim_data('SmallSimData.ellip');
n_points=size(sim_data,1);
wall_times=rand(n_points,1)*90.0; %Distribute data over 90 days
wall_times=wall_times+datenum(2011,11,4,0,0,0); %Add big offset, since our
    %real data will have one on this order of magnitude
t_z_array=[wall_times,sim_data(1:end,2)];
clearvars sim_data n_points wall_times
