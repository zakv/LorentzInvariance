classdef Position_Generator < handle
    %Class for generating z-positions of events
    
    properties
        left_data_set_list %For storing Tracer_Data_Sets with quip left, its
        %entries are sorted by charge
        right_data_set_list %For stroing Tracer_Data_Sets with quip right, its
        %entries are sorted by charge
        random_generator %Random number generator object
        rand %Replacement function for rand.  Takes n_elements as an
        %argument and returns a vector of random numbers of that legnth.
    end
    
    methods
        
        function self = Position_Generator(varargin)
            %Intializes an Event Generator instance
            %   A tracer file name and random generator seed can optionally
            %   be specified (call the function with two arguments in that
            %   order).
            
            %Default values
            random_generator=Random_Generator(); %#ok<PROP>
            
            %Interpret input
            if length(varargin)>=1
                if isnumeric(varargin{1})
                    seed=varargin{1};
                    random_generator=Random_Generator(seed); %#ok<PROP>
                end
            end
            
            %Perform intialization
            self.left_data_set_list={};
            self.right_data_set_list={};
            self.load_tracer_data();
            self.random_generator=random_generator; %#ok<PROP>
            self.rand=@random_generator.rand; %#ok<PROP>
        end
        
        function z_positions = generate_z_positions(self,charges,n_left)
            %Returns an array giving z_positions (in meters) which are
            %picked using the given charges
            %   charges should be an array of fractional charges (on the
            %   order of 1e-8) which are used to pick z-positions.  The
            %   first n_left charges are assumed to be quip left
            n_events=length(charges);
            z_positions=zeros(n_events,1);
            for j=1:n_events
                if j<=n_left
                    quip_index=1; %quip left
                else
                    quip_index=2; %quip right
                end
                z_positions(j)=self.get_one_z_position(charges(j),quip_index);
            end
        end
        
    end
    
    methods (Hidden)
        
        function [] = load_tracer_data(self)
            %Loads the tracer data (z-positions) into memory
            
            %Get all the filenames and load them into Tracer_Data_Set
            %instances
            tracer_output_dir=Tracer_Data_Set.TRACER_DATA_DIR;
            search_string=fullfile(tracer_output_dir,'SimData_*.mat');
            file_list=dir(search_string);
            file_name_list={file_list.name};
            jMax=length(file_name_list);
            for j=1:jMax
                file_name=file_name_list{j};
                tracer_data_set=Tracer_Data_Set(file_name);
                if strcmp(tracer_data_set.quip,'left')
                    self.left_data_set_list{end+1}=tracer_data_set;
                elseif strcmp(tracer_data_set.quip,'right')
                    self.right_data_set_list{end+1}=tracer_data_set;
                end
            end
            
            %Sort the lists
            for j1=1:2
                %Get unsorted list
                if j1==1
                    current_list=self.left_data_set_list;
                elseif j1==2
                    current_list=self.right_data_set_list;
                end
                
                %Perform actual sorting
                n_sets=length(current_list);
                sort_array=cell(n_sets,2);
                for j2=1:n_sets
                    sort_array{j2,1}=current_list{j2}.charge;
                    sort_array{j2,2}=current_list{j2};
                end
                sort_array=sortrows(sort_array,1);
                current_list=transpose( sort_array(:,2) );
                
                %Assign sorted list to self
                if j1==1
                    self.left_data_set_list=current_list;
                elseif j1==2
                    self.right_data_set_list=current_list;
                end
            end
        end
        
        function z_position = get_one_z_position(self,charge,quip_index,varargin)
            %Returns one z-position by choosing the appropriate cdfs and
            %interpolating
            %   quip_index should be 1 for left or 2 for right.  rand_val
            %   can optionally be specified as an additional argument
            %   (useful for debugging and for one of the plots).
            
            rand_val=self.rand(1); %random number used to pick position
            if ~isempty(varargin)
                rand_val=varargin{1}; %Overwrite the randomly chosen value
            end
            
            %Figure out which Tracer_Data_Sets to use.
            if quip_index==1
                tracer_set_list=self.left_data_set_list;
            elseif quip_index==2
                tracer_set_list=self.left_data_set_list;
            end
            
            charge_too_small=charge<tracer_set_list{1}.charge;
            charge_too_large=charge>tracer_set_list{end}.charge;
            
            if charge_too_small || charge_too_large
                msgIdent='Position_Generator:get_one_z_position:';
                msgIdent=[msgIdent,'InvalidCharge'];
                msgString='The given charge of %e is outside the range ';
                msgString=[msgString,'of Tracer Data'];
                error(msgIdent,msgString,charge);
            end
            
            if charge==tracer_set_list{1}.charge
                z_position=self.interpolate_z_cdf(tracer_set_list{1},rand_val);
                return
            elseif charge==tracer_set_list{end}.charge
                z_position=self.interpolate_z_cdf(tracer_set_list{end},rand_val);
                return
            end
            
            right_index=1;
            too_small=true;
            while too_small
                right_index=right_index+1;
                too_small=tracer_set_list{right_index}.charge<charge;
            end
            left_tracer_set=tracer_set_list{right_index-1};
            right_tracer_set=tracer_set_list{right_index};
            
            %Now we have the proper data sets.  Time to interpolate
            left_z_position=self.interpolate_z_cdf(left_tracer_set,rand_val);
            right_z_position=self.interpolate_z_cdf(right_tracer_set,rand_val);
            %The following looks like it's switched, but is correct
            right_weight=charge-left_tracer_set.charge;
            left_weight=right_tracer_set.charge-charge;
            weight_sum=left_weight+right_weight;
            z_position=(left_weight*left_z_position+ ...
                right_weight*right_z_position)/weight_sum;
        end
        
    end
    
    methods (Hidden,Static)
        
        function z_position = interpolate_z_cdf(tracer_data_set,rand_val)
            %Returns one z-position using the cdf inferred from
            %tracer_data_set.  This should be one of two values used to get
            %a weighted average between the cdf's of two different charges.
            cdf_array=tracer_data_set.z_positions;
            z_position=Position_Generator.cdf_pick(cdf_array,rand_val);
        end
        
        function value = cdf_pick(cdf_array,rand_val)
            %Picks a value from a CDF using cdf_array at a position chosen
            %by rand_val
            %   cdf_arrary should be a 1d array of sorted values
            %   (z-positions for example).  rand_val should be a random
            %   number between 0 and 1.
            %   Performs a linear interpolation between entries in
            %   cdf_array.
            index_scale=length(cdf_array)-1;
            index=index_scale*rand_val+1;
            left_index=floor(index);
            right_index=left_index+1;
            %The following looks like it's switched, but is correct
            right_weight=index-left_index;
            left_weight=right_index-index;
            left_value=cdf_array(left_index);
            right_value=cdf_array(right_index);
            value=left_weight*left_value+right_weight*right_value;
        end
            
    end
    
end

