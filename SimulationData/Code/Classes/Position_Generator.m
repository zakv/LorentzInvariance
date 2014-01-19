classdef Position_Generator < handle
    %Class for generating z-positions of events
    
    properties
        TRACER_FILE_NAME %Tracer file to use
        z_positions %z-positions from tracer file
        index_scale %Number to multiply random numbers by to get an index
        stream %Random number stream
        seed %Seed for random number stream
    end
    
    methods
        
        function self = Position_Generator()
            %Intiallizes an Event Generator instance
            self.TRACER_FILE_NAME=fullfile(Analysis.SIMULATION_DATA, ...
                'TracerOutput', ...
                'LargeSimData.mat'); %Tracer output file
            self.load_tracer_data(self);
            self.index_scale=length(self.z_positions);
            self.seed=mod(int32((now-today)*1000*feature('getpid')),2^32);
            self.stream=RandStream('twister','Seed',self.seed);
            rand(100); %Generate 10,000 numbers to get it well randomized (hopefully)
        end
        
        function [] = load_tracer_data(self)
            %Loads the tracer data (z-positions) into memory
            data_array=load_mat(self.TRACER_FILE_NAME);
            self.z_positions=data_array(:,2);
        end
        
        function z_positions = get_z_positions(self,n_events)
            %Returns an array giving z_positions (in meters) for n_events
            %   Right now this randomly picks positions from the tracer
            %   data: 'sample with replacement'
            numbers=rand(self.stream,1,n_events);
            indices=floor(self.index_scale*numbers+1); %Matlab indexing!
            z_positions=self.z_positions(indices);
        end
        
    end
    
end

