classdef Analysis < handle
    %Class to handle data manipulation and analysis for one time-generating
    %function.
    %   Read the documentation for further information
    
    properties (Constant,Hidden)
        %Properties of the Analysis Class
        SIMULATION_DATA='../../'; %Path to SimulationData/ (this file should
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
         
        %Tables
        table_dir %Directory where all the tables are stored
    end
    
    methods
        
        function self = Analysis(GENERATOR_NAME)
            %Initializes an Analysis object.
            
            addpath('../CorrelationFunctions/');
            addpath('../Mex/');
            addpath('../OtherFunctions/');
            addpath('../ParameterFunctions/');
            addpath('../SignalFunctions/');
            
            %Properties that vary between instances
            self.set_GENERATOR_NAME(GENERATOR_NAME);
            self.data_set_list={};
            self.signal_group_list={};
            
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
            %self.load_data_sets(); %Takes a long time and isn't
                %usually necessary
            
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
            
            %Add a few signal groups, suppress warning if they're already
            %in there.
            warning('off','Analysis:add_signal_group:FuncAlreadyAdded');
            warning('off','Analysis:add_signal_group:NameAlreadyAdded');
            self.add_signal_group(@signal_null,'null');
            self.add_signal_group(@(raw_data_set) ...
                signal_sine(raw_data_set,0.01,0.01,'day',0),'daily sine');
            warning('on','Analysis:add_signal_group:FuncAlreadyAdded');
            warning('on','Analysis:add_signal_group:NameAlreadyAdded');
            self.generate_signal_data_sets();
            disp(' ');
            disp(' ');
            
            self.generate_Charman_tables();
            disp(' ');
            disp(' ');
            
            self.generate_Charman_histograms();
            disp(' ');
            disp(' ');
            
            if close_pool_when_done==1
%                 matlabpool('close')
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
            
            %Erase all data_sets and other dependent data (this also fixes
            %issues with generating signal data sets caused by running
            %Analysis.run() more than once)
            self.clean_for_new_raw();
            
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
            
            close_pool_when_done=0;
            if matlabpool('size')==0
                matlabpool('open')
                close_pool_when_done=1;
            end
            
            %Define some constants for parfor loop
            save_data_set=@(data_set)self.save_data_set(data_set);
            data_set_list=cell(1,k_max);
            parfor k=1:k_max
                data_array=zeros(N_EVENTS,3); %allocate array
                data_array(1:end,1)=generate_event_times(); %assign time data
                data_array(1:end,2:3)=sim_data_slices{k}; %get t,z-positions
                %Create and Save a Data_Set instance
                data_set=Data_Set(self,k); 
                data_set.create_raw_data_set(data_array);
                save_data_set(data_set);
                data_set_list{k}=data_set;
            end
            
            %Update the data set list.  Kind of hack-ish to do it this way,
            %but necessary because of Matlab's parfor-loop rules
%             evalc('self.load_data_sets();');
            self.data_set_list(1:k_max)=data_set_list;
            self.reassign_analysis_parent() %reassign analysis parent after saving
            
            if close_pool_when_done==1
%                 matlabpool('close')
            end
            
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
            
            close_pool_when_done=0;
            if matlabpool('size')==0
                matlabpool('open')
                close_pool_when_done=1;
            end
            
            %Define some stuff for the parfor loop
            data_set_list=self.data_set_list;
            jMax=length(data_set_list);
            parfor j=1:jMax
                data_set=data_set_list{j};
                data_set.create_calc_data_set();
%                 data_set_list{j}=data_set; %Somehow should help with parfor issues
            end
            
%             self.data_set_list(1:jMax)=data_set_list; %Somehow should help
            %with parfor issues
            
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
            start_time=clock; %same as 'tic;' but won't get messed up when subfunctions call tic
            
            close_pool_when_done=0;
            if matlabpool('size')==0
                matlabpool('open')
                close_pool_when_done=1;
            end
            
            %Figure out  which signal data sets need to be generated
            %andwhat's the most data_sets needed for any signal group.
            %Also recreate any directories that may have been deleted.
            jMax_data_sets=0;
            n_groups=length(self.signal_group_list);
            generate_list={};
            for j=1:n_groups
                signal_group=self.signal_group_list{j};
                if exist(signal_group.signal_dir,'dir')~=7
                    mkdir(signal_group.signal_dir);
                end
                signal_group.reset_n_sets(); %Make sure thie n_sets value is sane
                if ~signal_group.is_generated()
                    jMax_data_sets=max(jMax_data_sets,signal_group.n_sets);
                    generate_list{end+1}=signal_group; %#ok<AGROW>
                end
            end
            
            %Define some constants for parfor loop
            data_set_list=self.data_set_list(1:jMax_data_sets);
            signal_group_list=generate_list;
            save_data_set=@(data_set)self.save_data_set(data_set);
            parfor j1=1:jMax_data_sets
                data_set=data_set_list{j1};
                data_set.load_raw_data_set();
                for j2=1:n_groups
                    signal_group=signal_group_list{j2}; %#ok<PFBNS>
                    signal_group.generate_signal_data_set(data_set);
                end
                data_set.unload_raw_data_set();
                save_data_set(data_set) %To save its signal_table
                data_set_list{j1}=data_set; %Somehow should help with parfor issues
            end
            
            %The way handle objects work gets messed up by parfor loop, so
            %we'll reassign the data here
            self.data_set_list(1:jMax_data_sets)=data_set_list;
            
            if close_pool_when_done==1
%                 matlabpool('close')
            end
            
            elapsed_time=etime(clock,start_time);
            disp('Finished generating signal data sets');
            fprintf('Generating signal data sets took %0.2f seconds\n',elapsed_time);
            
        end
        
        function [] = generate_Charman_tables(self)
            %Creates a table with results from the two Charman algorithms
            %for periods of both day and year
            
            %Load data_sets if necessary
            if isempty(self.data_set_list)
                self.load_data_sets();
            end
            data_set_list=self.data_set_list;
            if isempty(data_set_list)
                msgIdent='Analysis:generate_Charman_tables:NoDataSets';
                msgString='Please generate the data_sets before ';
                msgString=[msgString,'generating Charman_tables'];
                error(msgIdent,msgString);
            end
            
            disp('Generating Charman tables...');
            addpath ../../CharmanUltra/
            start_time=clock; %same as 'tic;' but won't get messed up when subfunctions call tic
            
            close_pool_when_done=0;
            if matlabpool('size')==0
                matlabpool('open')
                close_pool_when_done=1;
            end
            
            %Initializing variables that are sent to workers
            signal_group_list=self.signal_group_list;
            jMax_signal_group=length(signal_group_list);
            for j_signal_group=1:jMax_signal_group
                signal_group_list{j_signal_group}.generate_Charman_table();
            end
            
            if close_pool_when_done==1
%                 matlabpool('close')
            end
            
            disp('Finished generating Charman tables');
            elapsed_time=etime(clock,start_time);
            fprintf('Generating Charman table took %0.2f seconds\n',elapsed_time);
        end
        
        function [] = generate_Charman_histograms(self,varargin)
            %Generates and saves histograms of data from self.Charman_table
            %    By default this function will plot the first signal group
            %    (null) and last signal group (most recently added) with 30
            %    bins.  Passing a cell array with group names will cause
            %    the function to plot those groups, with the first one
            %    setting the bin center positions.  Passing in a numeric
            %    value will set the number of bins.
            
            %Defaults
            signal_group_list={ ...
                self.signal_group_list{1}, ...
                self.signal_group_list{end}, ...
                };
            n_bins=30;
            
            %Interpret input
            convert_names=false;
            nVararg=length(varargin);
            for j=1:nVararg
                current_arg=varargin{j};
                if iscell(current_arg)
                    signal_name_list=current_arg;
                    convert_names=true;
                elseif isnumeric(current_arg)
                    n_bins=round(current_arg);
                else
                    msgIdent='Analysis:generate_Charman_histograms:InvalidArgument';
                    msgString='Invalid argument.  Try harder next time.';
                    error(msgIdent,msgString);
                end
            end
            %Convert names to signal group instances if necessary
            if convert_names
                jMax=length(signal_name_list);
                signal_group_list=cell(1,jMax);
                for j=1:jMax
                    signal_name=signal_name_list{j};
                    signal_group_list{j}= ...
                        self.signal_group_name_to_instance(signal_name);
                end
            end
            
            %Make sure Charman_tables are generated and loaded
            jMax_signal_group=length(signal_group_list);
            for j=1:jMax_signal_group
                signal_group=signal_group_list{j};
                if isempty(signal_group.Charman_table)
                    if signal_group.Charman_table_file_exists()
                        signal_group.load_Charman_table();
                    else
                        signal_group.generate_Charman_table();
                    end
                end
            end
            
            disp('Generating Charman histograms...');
            tic;
            data_strings={ ... %data_type value then name for plot
                'z-position','z-position'; ...
%                 'wait_time','wait time'; ...
                };
            algorithm_period_strings={ ...
%                 'Charman II', 'year'; ...
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
                    
                    %Do first histogram
                    signal_group=signal_group_list{1};
                    S_array=Analysis.extract_S_array(signal_group,data_string, ...
                        algorithm_string, period_string);
                    bin_height=zeros(n_bins,jMax_signal_group);
                    [bin_count,bin_center]=hist(S_array,n_bins);
                    bin_height(:,1)=bin_count/sum(bin_count);
                    
                    %Do the rest of the histograms given the bin centers
                    %from above.
                    for j_signal_group=2:jMax_signal_group
                        signal_group=signal_group_list{j_signal_group};
                        S_array=Analysis.extract_S_array(signal_group,data_string, ...
                            algorithm_string, period_string);
                    [bin_count,bin_center]=hist(S_array,n_bins);
                    bin_height(:,j_signal_group)=bin_count/sum(bin_count);
                    end
                    
                    %Get names for legend
                    legend_names=cell(1,jMax_signal_group);
                    for j_signal_group=1:jMax_signal_group
                        signal_group=signal_group_list{j_signal_group};
                        legend_names{j_signal_group}=signal_group.signal_name;
                    end
                    figure('WindowStyle','docked');
                    bar(bin_center,bin_height,'hist');
                    title([algorithm_string,' - ',period_string,' - ',data_name]);
                    legend(legend_names);
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
            n_sets=0; %lets signal group choose the default
            
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
            already_used=false;
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
                    warning(msgIdent,msgString,func2str(signal_func));
                    already_used=true;
                elseif names_equal
                    msgIdent='Analysis:add_signal_group:NameAlreadyAdded';
                    msgString='The given function name %s is already in ';
                    msgString=[msgString,'self.signal_group_list']; %#ok<AGROW>
                    warning(msgIdent,msgString,signal_name);
                    already_used=true;
                end
            end
            
            %Actually create signal_group, add it to the list, and create
            %its directory if its not already used
            if ~already_used
                signal_group=Signal_Group(self,signal_func,signal_name,n_sets);
                self.signal_group_list{end+1}=signal_group;
                if exist(signal_group.signal_dir,'dir')~=7
                    mkdir(signal_group.signal_dir);
                end
                self.save_signal_group_list();
            end
        end
        
        function [] = delete_signal_group(self,signal_name)
            %Deletes the signal_group
            
            %Get the signal_group instance
            [signal_group,signal_group_index]= ...
                self.signal_group_name_to_instance(signal_name);
            
            %Remove directrory if it exists
            if exist(signal_group.signal_dir,'dir')==7
                rmdir(signal_group.signal_dir,'s');
            end
            
            %Remove its table directory
            if exist(signal_group.table_dir,'dir')==7
                rmdir(signal_group.table_dir,'s');
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
        
        function [signal_group,list_index] = signal_group_name_to_instance(self,signal_name)
            %Returns the signal_group instance with the given name and its
            %index in self.signal_group_list
            jMax=length(self.signal_group_list);
            j=1;
            found=false;
            while j<=jMax && found==false
                current_signal_group=self.signal_group_list{j};
                if strcmp(current_signal_group.signal_name,signal_name)
                    found=true;
                    signal_group=current_signal_group;
                    list_index=j;
                end
                j=j+1;
            end
            if found==false
                msgIdent='Analysis:signal_group_name_to_obj:InvalidName';
                msgString='No group with name %s exists';
                error(msgIdent,msgString,signal_name);
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
%             self.Charman_file_name=fullfile(self.table_dir,'Charman_table.mat');
            file_name='signal_group_list.mat';
            self.signal_group_file_name=fullfile(self.signal_data_set_root,file_name);
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
            elseif strcmp(file_name,'medium')
                file_name='MediumSimData.mat';
            end
            self.TRACER_FILE_NAME=fullfile(Analysis.SIMULATION_DATA, ...
                'TracerOutput', ...
                file_name);
            
            %Erase data since there's no point in resetting the tracer file
            %unless you're going to generate new data
            self.clean_for_new_raw();
            
            %Reset signal_group.n_sets to its default value
            signal_group_list=self.signal_group_list;
            jMax=length(signal_group_list);
            for j=1:jMax
                signal_group=signal_group_list{j};
                signal_group.assign_n_sets(0);
            end
        end
        
        function [] = clean_for_new_raw(self)
            %Cleans up self.data_set_root to help with some bugs that can
            %occur if self.generate_raw_data_sets() is run multiple times
            %without deleting the dependent data
            
            %First erase signal_data_sets since leaving these around causes
            %the biggest issues
            signal_group_list=self.signal_group_list;
            jMax=length(signal_group_list);
            for j=1:jMax
                signal_group=signal_group_list{j};
                signal_dir=signal_group.signal_dir;
                if exist(signal_dir,'dir')==7
                    rmdir(signal_dir,'s');
                    mkdir(signal_dir);
                end
            end
            
            %Delete raw and calc data sets and tables
            dir_list={ ...
                self.calc_data_set_dir, ...
                self.raw_data_set_dir, ...
                self.data_set_dir, ...
                self.table_dir, ...
                };
            jMax=length(dir_list);
            for j=1:jMax
                current_dir=dir_list{j};
                if exist(current_dir,'dir')==7
                    rmdir(current_dir,'s');
                    mkdir(current_dir);
                end
            end
            
            %Delete data set list
            self.data_set_list={};
            
            %Delete Charman tables from signal groups
            signal_group_list=self.signal_group_list;
            jMax=length(signal_group_list);
            for j=1:jMax
                signal_group=signal_group_list{j};
                signal_group.delete_Charman_table();
            end
        end
                
        function [] = save_data_set(self,data_set)
            %Saves a Data_Set object
            if isempty(data_set.raw_data_set) && isempty(data_set.calc_data_set)
                data_set.set_analysis_parent([]); %So save_mat doesn't save the parent as well
                OUTPUT_FILE_ROOT=fullfile(self.data_set_dir, ...
                    Analysis.DATA_SET_PREFIX);
                index=data_set.index;
                out_file_name=strcat(OUTPUT_FILE_ROOT,int2str(index),'.mat');
                save_mat(out_file_name,data_set);
%                 data_set.set_analysis_parent(self);
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
        
        function [] = reassign_analysis_parent(self)
            %Reassigns the analysis_parent property of all data sets to
            %self
            jMax=length(self.data_set_list);
            for j=1:jMax
                data_set=self.data_set_list{j};
                data_set.set_analysis_parent(self);
            end
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
        
        function bool = signal_group_file_exists(self)
            %Checks if there is a saved signal_group_list file
            if exist(self.signal_group_file_name,'file')==2
                bool=true;
            else
                bool=false;
            end
        end
        
    end %End of hidden methods
    
    methods (Hidden, Static)
        
        function S_array = extract_S_array(signal_group,data_string, ...
                algorithm_string, period_string)
            %Helper function used by generate_Charman_histograms
            Charman_table=signal_group.Charman_table;
            temp_table=filter_table(Charman_table, ...
                'data_type',data_string, ...
                'algorithm',algorithm_string, ...
                'period',period_string);
            left_table=filter_table(temp_table,'direction','left');
            right_table=filter_table(temp_table,'direction','right');
            S_array=Analysis.weighted_average(abs(left_table.A_1),abs(right_table.A_1));
        end
        
    end
    
end

