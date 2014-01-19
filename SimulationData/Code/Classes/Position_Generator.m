classdef Position_Generator < handle
    %Class for generating z-positions of events
    
    properties
        tracer_file_name %Tracer file to use
        z_positions %z-positions from tracer file
        index_scale %Number to multiply random numbers by to get an index
        random_generator %Random number generator object
        rand %Replacement function for rand.  Takes n_elements as an
        %argument and returns a vector of random numbers of that legnth.
    end
    
    methods
        
        function self = Position_Generator()
            %Intiallizes an Event Generator instance
            self.tracer_file_name=fullfile(Analysis.SIMULATION_DATA, ...
                'TracerOutput', ...
                'LargeSimDataSorted.mat'); %Tracer output file
            self.load_tracer_data();
            random_generator=Random_Generator();
            self.random_generator=random_generator();
            self.rand=@random_generator.rand;
        end
        
        function [] = set_tracer_file(self,file_name)
            %Sets and loads the given tracer file
            %   If file_name is 'all', 'large', or 'medium', the rest of
            %   the file_name will automatically be filled out
            
            %Check for special shortcut name arguments
            name_string=fullfile( ...
                Analysis.SIMULATION_DATA, ...
                'TracerOutput', ...
                '%sSimDataSorted.mat'); %Tracer output file
            if strcmp(file_name,'all')
                file_name=sprintf(name_string,'All');
            elseif strcmp(file_name,'large')
                file_name=sprintf(name_string,'Large');
            elseif strcmp(file_name,'medium')
                file_name=sprintf(name_string,'Medium');
            end
            
            self.tracer_file_name=file_name;
            self.load_tracer_data();
        end
        
        function [] = load_tracer_data(self)
            %Loads the tracer data (z-positions) into memory
            data_array=load_mat(self.tracer_file_name);
            self.z_positions=data_array(:,2);
            self.index_scale=length(self.z_positions);
        end
        
        function z_positions = generate_z_positions(self,n_events)
            %Returns an array giving z_positions (in meters) for n_events
            %   Right now this randomly picks positions from the tracer
            %   data: 'sample with replacement'
            numbers=self.rand(n_events);
            indices=floor(self.index_scale*numbers+1); %Matlab indexing!
            z_positions=self.z_positions(indices);
        end
        
    end
    
end

