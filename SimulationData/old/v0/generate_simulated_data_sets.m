function [ ] = generate_simulated_data_sets( file_name )
%Given the file_name of a simulation output .mat file, it will create and
%save a series of simulated data sets.
%   The function takes times from generate_event_times() and pairs them
%   with wait times and z-positions from the simulation data.  This data is
%   stored as an array with three columns: the first is the time in
%   datenum() format of the event, the second is the wait time, and the
%   third is the z-position of the event.
    
    %Define some constants and choose data type
    OUTPUT_FILE_ROOT='../DataSetOutput/data_set_';
    %OUTPUT_FILE_EXTENSION='.set';
    OUTPUT_FILE_EXTENSION='.mat';
    
                  
                  
    tic;
    %Retrieve simulation data
    sim_data=load_mat(file_name);
    N_DATA_POINTS=size(sim_data,1);
    disp('N_DATA_POINTS')
    disp(N_DATA_POINTS)
    
    %Generate event times once to see how many events are in each data set
    event_times=generate_event_times();
    N_EVENTS=length(event_times);
    disp('N_EVENTS')
    disp(N_EVENTS)

    %Make data sets until we run out of simulation data
    disp('Slicing up data for parallelization');
    j_start=1; %begining index of slice of data
    j_end=j_start+N_EVENTS-1; %ending index of slice of data
    k=0;
    k_max=floor(N_DATA_POINTS/N_EVENTS);
    sim_data_slices=cell(k_max,1);
    while j_end<=N_DATA_POINTS
        k=k+1;
        sim_data_slices{k}=sim_data(j_start:j_end,1:2); %get z-positions
        j_start=j_start+N_EVENTS;
        j_end=j_end+N_EVENTS;
    end
    k_max=k; %just in case the above formula for k_max didn't work

    close_pool_when_done=0;
    if matlabpool('size')==0
        matlabpool('open')
        close_pool_when_done=1;
    end
    disp('Beginning main iteration');
    parfor k=1:k_max
        data_array=zeros(N_EVENTS,3); %allocate array
        data_array(1:end,1)=generate_event_times(); %assign time data
        data_array(1:end,2:3)=sim_data_slices{k}; %get t,z-positions
        out_file_name=strcat(OUTPUT_FILE_ROOT,int2str(k),OUTPUT_FILE_EXTENSION);
        if strcmp(OUTPUT_FILE_EXTENSION,'.set')
            write_data_set(out_file_name,data_array); %save output as text file
        elseif strcmp(OUTPUT_FILE_EXTENSION,'.mat')
            save_mat(out_file_name,data_array);
        else
            disp('OUTPUT_FILE_EXTENSION must be ''.mat'' or ''.set''');
        end
    end
    if close_pool_when_done==1
        matlabpool('close')
    end
    
    disp('Generated this many data sets:');
    disp(k_max);
    disp('Took this long (seconds):');
    disp(toc);
end
