classdef Analysis < handle
    %Class to handle data manipulation and analysis for one time-generating
    %function.
    %   Read the documentation for further information
    
    properties (Constant,Hidden)
        %Properties of the Analysis Class
        SIMULATION_DATA='../'; %Path to SimulationData/ (this file should
        %be in SimulationData/code/)
        N_EVENTS=386; %Number of events per Data_Set
        N_LEFT=145; %Number of quip left data points.
        N_RIGHT=Analysis.N_EVENTS-Analysis.N_LEFT; %Number of quip left data points
        RAW_DATA_SET_PREFIX='raw_data_set_';
        CALC_DATA_SET_PREFIX='calc_data_set_';
        SIGNAL_DATA_SET_PREFIX='signal_data_set_';
        DATA_SET_PREFIX='data_set_';
        
        %Functions that calculate parameters of interest, each should take
        %a calc_data_set instance and a direction as arguments.
        PARAM_FUNCS={ ...
            @(data_set,direction)param_speed(data_set,direction),'Speed'; ...
            };
        
        %Functions that calculate correlation values with the different
        %algorithms.  First argument should be a column of data (wait times
        %or z-positions) and second argument should be a column of
        %parameters of interest.
        CORR_FUNCS={ ...
            @(data,param)corr(data,param,'type','Pearson'), 'Pearson';  ...
            @(data,param)corr(data,param,'type','Kendall'), 'Kendall'; ...
            @(data,param)corr(data,param,'type','Spearman'), 'Spearman';  ...
            };
    end
    
    properties (SetAccess=private)
        %Properties of instances of the Analysis Class that should not be
        %hidden
        TRACER_FILE_NAME=fullfile(Analysis.SIMULATION_DATA, ...
            'TracerOutput', ...
            'LargeSimData.mat'); %Tracer output file
        GENERATOR_NAME %Name for generate_event_times() function
        data_set_list %List of Data_Set objects
        signal_group_list %List of the instances signal groups, each of which is
            %a group of raw data sets with a signl added
        %Data Tables
        Charman_table %Results from Andy's algorithms
    end
    
    properties (SetAccess=private)
        %Dependent properties of instances of the Analysis Class that
        %should not be hidden
        
        data_set_root %Location of generate_event_times.m and
        %RawDataSets/ and DataSets/
    end
    
    properties (Hidden,SetAccess=private)
        %Dependent properties of instances of the Analysis Class that
        %should be hidden.
        
        %RawDataSets/ and DataSets/ and SignalDataSets/
        raw_data_set_dir %Directory where all the Raw_Data_Sets are stored
        calc_data_set_dir %Directory where all the Calc_Data_Sets are stored
        data_set_dir %Directory where all the data sets are stored
        signal_data_set_root %Directory that contains all of the signal data set
            %directories
        signal_group_file_name %File name to save the signal_group_list
         
        %Charman table
        table_dir %Directory where all the tables are stored
        Charman_file_name %File name (including relative path)
    end
    
    methods
        
        function self = Analysis(GENERATOR_NAME)
            %Initializes an Analysis object.
            
            %Properties that vary between instances
            self.set_GENERATOR_NAME(GENERATOR_NAME);
            self.data_set_list={};
            self.signal_group_list={};
            self.Charman_table=[];
            
            %Create subdirectories if necessary
            subdirectory_list={ ...
                self.raw_data_set_dir; ...
                self.calc_data_set_dir; ...
                self.data_set_dir; ...
                self.table_dir; ...
                self.signal_data_set_root; ...
                };
            jMax_subdirectory=size(subdirectory_list,1);
            for j=1:jMax_subdirectory
                subdirectory=subdirectory_list{j};
                if exist(subdirectory,'dir')~=7
                    mkdir(subdirectory);
                end
            end
            
            %Load Data_Sets in case they've already been generated
            %self.load_data_sets();
            
            %Load Charman_table if there is a saved copy
            if self.Charman_table_file_exists()
                self.load_Charman_table();
            end
            
            %Load signal_group_list list if there is a saved copy
            if self.signal_group_file_exists()
                self.load_signal_group_list();
            end
        end
        
        function [] = run(self)
            %Automatically performs the analysis
            close_pool_when_done=0;
            if matlabpool('size')==0
                matlabpool('open')
                close_pool_when_done=1;
            end
            
            self.generate_raw_data_sets();
            disp(' ');
            disp(' ');
            
            self.generate_calc_data_sets();
            disp(' ');
            disp(' ');
            
            self.generate_Charman_table();
            disp(' ');
            disp(' ');
            
            self.generate_Charman_histograms();
            disp(' ');
            disp(' ');
            
            if close_pool_when_done==1
%                 matlabpool('close')
            end
        end
        
        function new = deep_copy(self)
            % Create a new copy in memory
            new = feval(class(self),self.GENERATOR_NAME);
            
            % Copy all properties.
            p = fieldnames(struct(self));
            for i = 1:length(p)
                new.(p{i}) = self.(p{i});
            end
        end
        
        function [] = generate_raw_data_sets(self)
            %Generates the Raw_Data_Sets using the generate_event_times.m file
            %stored in self.data_set_root
            
            disp('Generating raw data sets...');
            
            %Make sure no other generate_event_times() is in path
            warning('off','MATLAB:rmpath:DirNotFound');
            rmpath(self.data_set_root);
            if exist('generate_event_times','file')==2
                msgIdent='Analysis:generate_simulated_data_sets:';
                msgIdent=[msgIdent,'Multiple_generate_event_times'];
                msgString='A function named generate_event_times is in the';
                msgString=[msgString,' Path and will take precedence over'];
                msgString=[msgString,' the proper function. Please remove it'];
                error(msgIdent,msgString);
            end
            warning('on','MATLAB:rmpath:DirNotFound');
            addpath(self.data_set_root);
            
            start_time=clock; %same as 'tic;' but won't get messed up when subfunctions call tic
            %Retrieve simulation data
            sim_data=load_mat(self.TRACER_FILE_NAME);
            N_DATA_POINTS=size(sim_data,1);
            fprintf('Number of events from Tracer data: %d\n',N_DATA_POINTS);
            
            %Display number of events in each Data_Set
            N_EVENTS=Analysis.N_EVENTS; %#ok<*PROP>
            fprintf('Number of events per data set: %d\n',N_EVENTS);
            
            %Make data sets until we run out of simulation data
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
            
            %Define some constants for parfor loop
            save_data_set=@(data_set,index) ...
                self.save_data_set(data_set,index);
            
            close_pool_when_done=0;
            if matlabpool('size')==0
                matlabpool('open')
                close_pool_when_done=1;
            end
            parfor k=1:k_max
                data_array=zeros(N_EVENTS,3); %allocate array
                data_array(1:end,1)=generate_event_times(); %assign time data
                data_array(1:end,2:3)=sim_data_slices{k}; %get t,z-positions
                %Create and Save a Data_Set instance
                data_set=Data_Set(self,k); 
                data_set.create_raw_data_set(data_array);
                save_data_set(data_set,k);
            end
            if close_pool_when_done==1
%                 matlabpool('close')
            end
            
            %Update the data set list.  Kind of hack-ish to do it this way,
            %but necessary because of Matlab's parfor-loop rules
            evalc('self.load_data_sets();');
            
            elapsed_time=etime(clock,start_time);
            disp('Finished generating raw data sets');
            fprintf('Generated %d raw data sets\n',k_max);
            fprintf('Generating raw data sets took %0.2f seconds\n',elapsed_time);
            
            rmpath(self.data_set_root);
        end
        
        function [] = generate_calc_data_sets(self)
            %Generates and saves the Calc_Data_Set instances
            disp('Generating calculated data sets...');
            tic;
            data_set_list=self.data_set_list;
            jMax=length(data_set_list);
            
            close_pool_when_done=0;
            if matlabpool('size')==0
                matlabpool('open')
                close_pool_when_done=1;
            end
            
            parfor j=1:jMax
                data_set=data_set_list{j};
                data_set.create_calc_data_set();
            end
            
            if close_pool_when_done==1
%                 matlabpool('close')
            end
            
            disp('Finished generating calculated data sets');
            fprintf('Generating calculated data sets took %0.2f seconds\n',toc);
        end
        
        function [] = generate_signal_data_sets(self)
            %Creates signal data sets for each element of
            %self.signal_group_list
            disp('Generating signal data sets for each signal group...');
            tic;
            
            close_pool_when_done=0;
            if matlabpool('size')==0
                matlabpool('open')
                close_pool_when_done=1;
            end
            
            %Figure out  what's the most data_sets needed for any signal
            %group.  Also recreate any directories that may have been
            %deleted.
            jMax_data_sets=0;
            n_groups=length(self.signal_group_list);
            for j=1:n_groups
                signal_group=self.signal_group_list{j};
                jMax_data_sets=max(jMax_data_sets,signal_group.n_sets);
                if exist(signal_group.signal_dir,'dir')~=7
                    mkdir(signal_group.signal_dir);
                end
            end
            
            data_set_list=self.data_set_list(1:jMax_data_sets);
            signal_group_list=self.signal_group_list;
            parfor j1=1:jMax_data_sets
                data_set=data_set_list{j1};
                data_set.load_raw_data_set();
                for j2=1:n_groups
                    signal_group=signal_group_list{j2}; %#ok<PFBNS>
                    signal_group.generate_signal_data_set(data_set);
                end
                data_set.unload_raw_data_set();
            end
            
            if close_pool_when_done==1
%                 matlabpool('close')
            end
            
            disp('Finished generating signal data sets');
            fprintf('Generating signal data sets took %0.2f seconds\n',toc);
            
        end
        
        function [] = generate_Charman_table(self)
            %Creates a table with results from the two Charman algorithms
            %for periods of both day and year
            
            %Load data_sets if necessary
            if isempty(self.data_set_list)
                self.load_data_sets();
            end
            data_set_list=self.data_set_list;
            if isempty(data_set_list)
                msgIdent='Analysis:generate_Charman_table:NoDataSets';
                msgString='Please generate and save the data_sets before ';
                msgString=[msgString,'generating Charman_table'];
                error(msgIdent,msgString);
            end
            jMax_data_set=length(data_set_list);
            
            disp('Generating Charman table...');
            addpath ../../CharmanUltra/
            tic;
            
            close_pool_when_done=0;
            if matlabpool('size')==0
                matlabpool('open')
                close_pool_when_done=1;
            end
            
            algorithm_list={ ...
                @(date_times,data,period)CharmanII(date_times,data,period), 'Charman II';
                @(date_times,data,period)CharmanIV(date_times,data,period), 'Charman IV';
                };
            period_list={ ...
                'day','day';
                'year','year';
                };
            data_type_list={ ...
                1,'z-position'; ...
                2,'wait_time'; ...
                };
            direction_list={ ...
                1,'left'; ...
                2,'right'; ...
                3,'averaged'; ...
                };
            jMax_algorithm=size(algorithm_list,1);
            jMax_period=size(period_list,1);
            jMax_data_type=size(data_type_list,1);
            
            %Initialize variables that are divided among workers
            weighted_average=@self.weighted_average;
            data_set_index_cell_array=cell(jMax_data_set,1);
            algorithm_cell_array=cell(jMax_data_set,1);
            period_cell_array=cell(jMax_data_set,1);
            data_type_cell_array=cell(jMax_data_type);
            direction_cell_array=cell(jMax_data_set,1);
            A_1_cell_array=cell(jMax_data_set,1);
            parfor j_data_set_index=1:jMax_data_set
                data_set=data_set_list{j_data_set_index};
                data_set.load_raw_data_set();
                raw_data_set=data_set.raw_data_set;
                
                rows_per_chunk=jMax_algorithm*jMax_period*jMax_data_type*3 %3 for direction
                data_set_index_chunk=zeros(rows_per_chunk,1);
                algorithm_chunk=cell(rows_per_chunk,1);
                period_chunk=cell(rows_per_chunk,1);
                data_type_chunk=cell(rows_per_chunk,1);
                direction_chunk=cell(rows_per_chunk,1);
                A_1_chunk=zeros(rows_per_chunk,1);
                j=1;
                for j_data=1:jMax_data_type %wait_times or z-position
                    data_type_name=data_type_list{j_data,2}; %#ok<PFBNS>
                    for j_algorithm=1:jMax_algorithm
                        algorithm=algorithm_list{j_algorithm,1}; %#ok<PFBNS>
                        algorithm_name=algorithm_list{j_algorithm,2};
                        for j_period=1:jMax_period
                            period=period_list{j_period,1}; %#ok<PFBNS>
                            period_name=period_list{j_period,2};
                            mini_A_1_array=zeros(1,2); %for averaging left/right data
                            for j_direction=1:2 %left then right, then averaged below
                                %j=(j_algorithm-1)*jMax_algorithm+j_period;
                                %j=(j-1)*3;
                                data_set_index_chunk(j)=j_data_set_index;
                                algorithm_chunk{j}=algorithm_name
                                period_chunk{j}=period_name;
                                data_type_chunk{j}=data_type_name;
                                direction_chunk{j}=direction_list{j_direction,2}; %#ok<PFBNS>
                                date_times=raw_data_set.get_date_times(j_direction);
                                data=raw_data_set.get_data(j_data,j_direction);
                                mini_A_1_array(j_direction)=algorithm(date_times,data,period);
                                A_1_chunk(j)=mini_A_1_array(j_direction);
                                j=j+1;
                            end
                            %averated left and right
                            j_direction=j_direction+1;
                            data_set_index_chunk(j)=j_data_set_index;
                            algorithm_chunk{j}=algorithm_name
                            period_chunk{j}=period_name;
                            data_type_chunk{j}=data_type_name;
                            direction_chunk{j}=direction_list{j_direction,2};
                            A_1_chunk(j)=weighted_average(mini_A_1_array(1),mini_A_1_array(2));
                            j=j+1;
                        end
                    end
                end
                data_set_index_cell_array{j_data_set_index}=data_set_index_chunk;
                algorithm_cell_array{j_data_set_index}=algorithm_chunk;
                period_cell_array{j_data_set_index}=period_chunk;
                data_type_cell_array{j_data_set_index}=data_type_chunk;
                direction_cell_array{j_data_set_index}=direction_chunk;
                A_1_cell_array{j_data_set_index}=A_1_chunk;
                data_set.unload_raw_data_set();
            end
            data_index=vertcat(data_set_index_cell_array{:});
            algorithm=categorical( vertcat(algorithm_cell_array{:}) );
            period=categorical( vertcat(period_cell_array{:}) );
            data_type=categorical( vertcat(data_type_cell_array{:}) );
            direction=categorical( vertcat(direction_cell_array{:}) );
            A_1=vertcat(A_1_cell_array{:});
            
            self.Charman_table=table(data_index,data_type,algorithm,period,direction,A_1);
            self.save_Charman_table();
            if close_pool_when_done==1
%                 matlabpool('close')
            end
            
            disp('Finished generating Charman table');
            fprintf('Generating Charman table took %0.2f seconds\n',toc);
        end
        
        function [] = generate_Charman_histograms(self,varargin)
            %Generates and saves histograms of data from self.Charman_table
            %   Optionally can specify the number of bins for the
            %   histograms as an additional argument
            
            %Check input
            n_varargs=length(varargin);
            if  n_varargs==0
                n_bins=25; %default value set here
            elseif n_varargs==1
                n_bins=varargin{1};
            elseif n_varargs>1
                msgIdent='Analysis:generate_Charman_histograms:TooManyArguments';
                msgString='Please either give no arguments, or just one giving the ';
                msgString=[msgString,'number of bins to use'];
                error(msgIdent,msgString);
            end
            
            if isempty(self.Charman_table)
                self.generate_Charman_table()
            end
            
            disp('Generating Charman histograms...');
            tic;
            data_strings={ ... %data_type calue then name for plot
                'z-position','z-position'; ...
                'wait_time','wait time'; ...
                };
            algorithm_period_strings={ ...
                'Charman II', 'year'; ...
                'Charman IV', 'day'; ...
                };
            jMax_data=size(data_strings,1);
            jMax_algorithm_period=size(algorithm_period_strings,1);
            
            for j_data=1:jMax_data
                data_string=data_strings{j_data,1};
                data_name=data_strings{j_data,2};
                for j_algorithm_period=1:jMax_algorithm_period
                    algorithm_string=algorithm_period_strings{j_algorithm_period,1};
                    period_string=algorithm_period_strings{j_algorithm_period,2};
                    temp_table=filter_table(self.Charman_table, ...
                        'data_type',data_string, ...
                        'algorithm',algorithm_string, ...
                        'period',period_string);
                    left_table=filter_table(temp_table,'direction','left');
                    right_table=filter_table(temp_table,'direction','right');
                    S_array=self.weighted_average(abs(left_table.A_1),abs(right_table.A_1));
                    figure('WindowStyle','docked');
                   [bin_count,bin_center]=hist(S_array,n_bins);
                    bin_height=bin_count/sum(bin_count);
                    bar(bin_center,bin_height,'hist');
                    title([algorithm_string,' - ',period_string,' - ',data_name]);
                    if strcmp(data_string,'z-position')
                        xlabel('S, weighted average of |A_1| (meters)');
                    elseif strcmp(data_string,'wait_time')
                        xlabel('S, weighted average of |A_1|, (seconds)');
                    end
                    ylabel('Normalized Count')
                end
            end
            
            disp('Finished generating Charman histograms');
            fprintf('Generating Charman histograms took %0.2f seconds\n',toc);
        end

        function [] = save_Charman_table(self)
            %Saves the Charman table to the Tables subdirectory
            Charman_table=self.Charman_table;
            if ~isempty(Charman_table)
                save_mat(self.Charman_file_name,Charman_table);
            else
                msgIdent='Analysis:save_Charman_table:TableEmpty';
                msgString='Cannot save Charman_table; it is currently empty';
                error(msgIdent,msgString);
            end
        end
        
        function [] = load_Charman_table(self)
            %Loads the Charman table from the Tables subdirectory
            if self.Charman_table_file_exists()
                self.Charman_table=load_mat(self.Charman_file_name);
            else
                msgIdent='Analysis:load_Charman_table:NoSavedTable';
                msgString='No Charman_table is saved';
                error(msgIdent,msgString);
            end
        end

        function [] = load_data_sets(self)
            %Loads Data_Sets into memory
            
            disp('Loading data sets...');
            tic;
            data_set_names=self.get_data_set_names();
            n_elements=numel(data_set_names);
            if n_elements==0
                self.data_set_list={};
            else
                self.data_set_list=cell(1,n_elements);
                indices=zeros(1,n_elements);
                for j=1:n_elements
                    file_name=data_set_names{j};
                    data_set=load_mat(file_name);
                    data_set.set_analysis_parent(self);
                    self.data_set_list{j}=data_set;
                    indices(j)=data_set.index;
                end
                [~,order]=sort(indices);
                self.data_set_list=self.data_set_list(order);
            end
            disp('Finished loading data sets');
            fprintf('Loading data sets took %0.2f seconds\n',toc);
        end
        
        function data_set = get_one_data_set(self)
            %Returns one new Data_Set.  Useful for debugging Data_Set.m
            if isempty(self.data_set_list)
                evalc('self.load_data_sets()');
            end
            if isempty(self.data_set_list)
                self.generate_raw_data_sets();
            end
            data_set=self.data_set_list{1};
        end
        
        function [] = set_tracer_file(self,file_name)
            %Selects a tracer data file
            %   file_name should be the name of a tracer data file in the
            %   direcotry SimulationData/TracerOutput/
            %   The current options are MediumSimData.mat and
            %   AllSimData.mat
            if strcmp(file_name,'all')
                file_name='AllSimData.mat';
            elseif strcmp(file_name,'large')
                file_name='LargeSimData.mat';
            end
            self.TRACER_FILE_NAME=fullfile(Analysis.SIMULATION_DATA, ...
            'TracerOutput', ...
            file_name); 
        end
        
        function [] = add_signal_group(self,signal_func,varargin)
            %Adds a signal group with the given data to
            %self.signal_group_list
             %   signal_func should be the handle to a function that takes
             %   a raw_data_set as an argument and returns a signal data
             %   set (which is a raw_data_set_instance with a signal
             %   added).
            %   You can also specify the signal_name or n_sets by passing
            %   keyword arguments.  signal_name is the name used to
            %   identify the signal function and n_sets is the number of
            %   data sets to apply it to.  If n_sets is larger than the
            %   number of data sets, all data sets will be used.
            
            %Make sure data sets are loaded
            if isempty(self.data_set_list)
                evalc('self.load_data_sets()');
            end
            if isempty(self.data_set_list)
                self.generate_raw_data_sets();
            end
            
            %Default values
            signal_name=func2str(signal_func);
            n_sets=max( 0.1*length(self.data_set_list),1000);
            
            %Interpret input
            nVarargs=length(varargin);
            do_while_loop=false;
            if nVarargs==1
                signal_name=varargin{1};
            elseif nVarargs==2
                if ismember(varargin{1},{'signal_name','n_sets'})
                    do_while_loop=true;
                else
                    signal_name=varargin{1};
                    n_sets=varargin{2};
                end
            else
                do_while_loop=true;
            end
            
            if do_while_loop
            j=1;
                while j<=nVarargs
                    if strcmp(varargin{j},'signal_name')
                        signal_name=varargin{j+1};
                        j=j+2;
                    elseif strcmp(varargin{j},'n_sets')
                        n_sets=varargin{j+1};
                        j=j+2;
                    else
                        msgIdent='Analysis:add_signal_group:InvalidArguments';
                        msgString='Invalid function call';
                        error(msgIdent,msgString);
                    end
                end
            end
            
            
            
            n_sets=floor(n_sets); %make sure it's an integer
            
            %Make sure signal_func and signal_name aren't already used
            jMax=length(self.signal_group_list);
            for j=1:jMax
                signal_group=self.signal_group_list{j};
                handles_equal=isequal(signal_func,signal_group.signal_func) ;
                strings_equal=strcmp( func2str(signal_func), ...
                    func2str(signal_group.signal_func) );
                names_equal=strcmp(signal_name,signal_group.signal_name);
                if handles_equal || strings_equal
                    msgIdent='Analysis:add_signal_group:FuncAlreadyAdded';
                    msgString='The given function %s is already in ';
                    msgString=[msgString,'self.signal_group_list']; %#ok<AGROW>
                    error(msgIdent,msgString,func2str(signal_func));
                elseif names_equal
                    msgIdent='Analysis:add_signal_group:NameAlreadyAdded';
                    msgString='The given function name %s is already in ';
                    msgString=[msgString,'self.signal_group_list']; %#ok<AGROW>
                    error(msgIdent,msgString,signal_name);
                end
            end
            
            %Actually create signal_group, add it to the list, and create
            %its directory
            signal_group=Signal_Group(self,signal_func,signal_name,n_sets);
            self.signal_group_list{end+1}=signal_group;
            if exist(signal_group.signal_dir,'dir')~=7
                mkdir(signal_group.signal_dir);
            end
            self.save_signal_group_list();
        end
        
        function [] = delete_signal_group(self,signal_name)
            %Deletes the signal_group
            jMax=length(self.signal_group_list);
            desired_signal_group=[];
            j=1;
            while j<=jMax && isempty(desired_signal_group)
                signal_group=self.signal_group_list{j};
                if strcmp(signal_name,signal_group.signal_name)
                    desired_signal_group=signal_group;
                    signal_group_index=j;
                end
                j=j+1;
            end
            
            if isempty(desired_signal_group)
                msgIdent='Analysis:delete_signal_group:InvalidSignalName';
                msgString='No signal group with signal anme %s exists';
                error(msgIdent,msgString,signal_name);
            end
            signal_group=desired_signal_group;
            
            %Remove directrory if it exists
            if exist(signal_group.signal_dir,'dir')==7
                rmdir(signal_group.signal_dir,'s');
            end
            
            %Delete its rows for all relevant data_set.signal_table
            jMax=signal_group.n_sets;
            for j=1:jMax
                data_set=self.data_set_list{j};
                if ismember(signal_name,data_set.signal_table.Properties.RowNames)
                    data_set.signal_table(signal_name,:)=[];
                end
            end
            
            %Delete from self.signal_group_list
            self.signal_group_list(signal_group_index)=[];
        end
        
        function [] = save_signal_group_list(self)
            %Save self.signal_group_list to the self.signal_data_set_root
            %directory
            
            %Erase analysis parent so the analysis instance does not get
            %saved
            jMax=length(self.signal_group_list);
            for j=1:jMax
                signal_group=self.signal_group_list{j};
                signal_group.set_analysis_parent([]);
            end
            
            %Save it
            save_mat(self.signal_group_file_name,self.signal_group_list);
            
            %Reassign analysis_parent
            jMax=length(self.signal_group_list);
            for j=1:jMax
                signal_group=self.signal_group_list{j};
                signal_group.set_analysis_parent(self);
            end
        end
        
        function [] = load_signal_group_list(self)
            %Loads the signal_group_list from the hard drive
            if exist(self.signal_group_file_name,'file')==2
                self.signal_group_list=load_mat(self.signal_group_file_name);
                %Set this analysis instance as the parent
                jMax=length(self.signal_group_list);
                for j=1:jMax
                    signal_group=self.signal_group_list{j};
                    signal_group.set_analysis_parent(self);
                end
            else
                msgIdent='Analysis:load_signal_group_list:NoSavedList';
                msgString='No signal_group_list is saved';
                error(msgIdent,msgString);
            end
        end
        
    end %End of methods
    
    methods (Static)
        
        function average = weighted_average(left_val,right_val)
            %Returns the weighted average of the two quantities, weighted by number
            %of quip left/right events.
            numerator=(Analysis.N_LEFT*left_val+Analysis.N_RIGHT*right_val);
            average=numerator/Analysis.N_EVENTS;
        end
        
    end %End of static methods
    
    methods (Hidden)
        
        function [] = set_GENERATOR_NAME(self,GENERATOR_NAME)
            %Sets GENERATOR_NAME and updates other properties that depend
            %on it.
            
            self.GENERATOR_NAME=GENERATOR_NAME;
            self.data_set_root=fullfile(Analysis.SIMULATION_DATA,'DataSets', ...
                self.GENERATOR_NAME);
            
            %Make sure proper folder with generate_event_times.m exists
            if exist(self.data_set_root,'dir')~=7
                msgIdent='Analysis:Analysis:DirDoesNotExist';
                msgString=['The directory ',self.data_set_root,' does not exist'];
                error(msgIdent,msgString);
            end
            
            self.raw_data_set_dir=fullfile(self.data_set_root, ...
                'RawDataSets');
            self.calc_data_set_dir=fullfile(self.data_set_root, ...
                'CalcDataSets');
            self.signal_data_set_root=fullfile(self.data_set_root, ...
                'SignalDataSets');
            self.data_set_dir=fullfile(self.data_set_root,'DataSets');
            self.table_dir=fullfile(self.data_set_root,'Tables');
            self.Charman_file_name=fullfile(self.table_dir,'Charman_table.mat');
            file_name='signal_group_list.mat';
            self.signal_group_file_name=fullfile(self.signal_data_set_root,file_name);
        end
                
        function [] = save_data_set(self,data_set,index)
            %Saves a Data_Set object
            if isempty(data_set.raw_data_set) && isempty(data_set.calc_data_set)
                data_set.set_analysis_parent([]); %So save_mat doesn't save the parent as well
                OUTPUT_FILE_ROOT=fullfile(self.data_set_dir, ...
                    Analysis.DATA_SET_PREFIX);
                out_file_name=strcat(OUTPUT_FILE_ROOT,int2str(index),'.mat');
                save_mat(out_file_name,data_set);
            else
                msgIdent='Analysis:save_data_set:OversizeDataSet';
                msgString='Please unload raw and calculated data before saving ';
                msgString=[msgString,'a Data_Set'];
                error(msgIdent,msgString)
            end
        end
        
        function data_set_names = get_data_set_names(self)
            %Returns a list of full paths to data sets
            search_string=fullfile(self.data_set_dir, ...
                [Analysis.DATA_SET_PREFIX,'*.mat']);
            file_list=dir(search_string);
            data_set_names=fullfile(self.data_set_dir,{file_list.name});
        end
        
        function bool = Charman_table_file_exists(self)
            %Returns true or false depending on whether or not the
            %Charman_table file exists
            if exist(self.Charman_file_name,'file')==2
                bool=true;
            else
                bool=false;
            end
        end
        
        function bool = signal_group_file_exists(self)
            %Checks if there is a saved signal_group_list file
            if exist(self.signal_group_file_name,'file')==2
                bool=true;
            else
                bool=false;
            end
        end
        
    end %End of hidden methods
    
end

