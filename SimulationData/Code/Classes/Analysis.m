classdef Analysis < handle
    %Class to handle data manipulation and analysis for one time-generating
    %function.
    %   Read the documentation for further information
    
    properties (Constant,Hidden)
        %Properties of the Analysis Class
        SIMULATION_DATA='../../'; %Path to SimulationData/ (this file should
        %be in SimulationData/code/)
        DATA_SET_PREFIX='data_set_';
        RAW_DATA_SET_PREFIX='raw_data_set_';
        CALC_DATA_SET_PREFIX='calc_data_set_';
        
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
        GENERATOR_NAME %Name for generate_event_times() function
        tracer_file_name%= ...
%             fullfile(Analysis.SIMULATION_DATA, ...
%             'TracerOutput', ...
%             'LargeSimData.mat'); %Tracer output file
        signal_group_list %List of the instances signal groups
        n_workers %Number of workers in parpool
    end
    
    properties (SetAccess=private)
        %Dependent properties of instances of the Analysis Class that
        %should not be hidden
        
        data_set_root %Location of generate_event_times.m and
        %the various signal group directories
    end
    
    properties (Hidden,SetAccess=private)
        %Dependent properties of instances of the Analysis Class that
        %should be hidden.
        
        signal_group_file_name %File name to save the signal_group_list
        position_generator_seeder %A prng based on a different (Lagged Fibnoacci)
        position_generator_list %List of the position generators
        tracer_file_name_file %File used to save the value of self.tracer_file_name
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
            self.signal_group_list={};
            seed=int32((10000*now-floor(now*10000))*10^9);
            self.position_generator_seeder= ...
                RandStream('multFibonacci','Seed',seed);
            self.position_generator_list={};
            
            %Load tracer_file_name if there is a saved copy, or else set it
            %to the default
            if self.tracer_file_name_file_exists()
                self.load_tracer_file_name()
            else
                self.set_tracer_file('large');
            end
            
            %Load signal_group_list list if there is a saved copy
            if self.signal_group_file_exists()
                self.load_signal_group_list();
            else
                %Add default signal groups
                self.add_signal_group(@signal_null,'null');
                self.add_signal_group(@(data_set) ...
                    signal_sine(data_set,0.01,'day',0),'daily sine');
            end
            
            %Set n_workers if a parpool exists
            if matlabpool('size')~=0
                pool_instance=gcp();
                self.n_workers=pool_instance.NumWorkers;
            end
            
        end
        
        function [] = set_tracer_file(self,tracer_name)
            %Selects a tracer data file for the position generators
            %   file_name should be the name of a tracer data file in the
            %   direcotry SimulationData/TracerOutput/ The current options
            %   are MediumSimDataSorted.mat, LargeDataSetSorted.mat and
            %   AllSimDataSorted.mat
            if strcmp(tracer_name,'all')
                tracer_name='AllSimDataSorted.mat';
            elseif strcmp(tracer_name,'large')
                tracer_name='LargeSimDataSorted.mat';
            elseif strcmp(tracer_name,'medium')
                tracer_name='MediumSimDataSorted.mat';
            end
            self.tracer_file_name=Analysis.interpret_tracer_name(tracer_name);
            
            %Update position generators
            jMax=length(self.position_generator_list);
            for j=1:jMax
                position_generator=self.position_generator_list{j};
                position_generator.set_tracer_file(self.tracer_file_name);
            end
            
            %Save the tracer_file_name
            self.save_tracer_file_name();
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
            %   data sets to make.
            
            %Default values
            signal_name=Analysis.func_to_signal_name(signal_func);
            n_sets=0; %lets signal group choose the default
            
            %Interpret input
            nVarargs=length(varargin);
            do_while_loop=false;
            if nVarargs==1
                %If there's one input, take it as the signal_name if its a
                %string or as n_sets if its a number
                if ischar(varargin{1})
                    signal_name=varargin{1};
                elseif isnumeric(varargin{1})
                    n_sets=varargin{1};
                end
            elseif nVarargs==2
                %If there are two args, check if one is a flag.  If not,
                %then assign the number to n_sets and the string to
                %signal_name
                if ismember(varargin{1},{'signal_name','n_sets'})
                    do_while_loop=true;
                else
                    for j=1:2
                        if ischar(varargin{j})
                            signal_name=varargin{j};
                        elseif isnumeric(varargin{j})
                            n_sets=varargin{j};
                        end
                    end
                end
            else
                %If there's more than two arguments, we'll do the while
                %loop to interpret the arguments.
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
            
            n_sets=round(n_sets); %make sure it's a positive integer
            if n_sets<0
                n_sets=0;
            end
            
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
            
            %Actually create signal_group and add it to the list
            if ~already_used
                signal_group=Signal_Group(self,signal_func,signal_name,n_sets);
                self.signal_group_list{end+1}=signal_group;
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
            
            %Delete from self.signal_group_list
            self.signal_group_list(signal_group_index)=[];
        end
        
        function [] = pop_signal_group(self)
            %Deletes the last signal group in signal_group_list
            self.delete_signal_group(self.signal_group_list{end}.signal_name);
        end
        
        function [] = run(self)
            %Automatically performs the analysis
            
            %Open a parpool if necessary, and add each worker's
            %position_generator
            self.start_parpool();
            
            %Generate the signal data for all the signal groups
            self.generate_signal_data();
            fprintf('\n');
            
            self.generate_Charman_histograms();
            fprintf('\n\n');
        end
        
        function [] = generate_signal_data(self)
            %Iterates over the signal groups and generates their data.
            
            %Make sure no other generate_event_times() is in path
            warning('off','MATLAB:rmpath:DirNotFound');
            rmpath(self.data_set_root);
            warning('on','MATLAB:rmpath:DirNotFound');
            if exist('generate_event_times.m','file')==2
                msgIdent='Analysis:generate_simulated_data_sets:';
                msgIdent=[msgIdent,'Multiple_generate_event_times'];
                msgString='A function named generate_event_times is in the';
                msgString=[msgString,' Path and will take precedence over'];
                msgString=[msgString,' the proper function. Please remove it'];
                error(msgIdent,msgString);
            end
            addpath(self.data_set_root);
            
            %Iterate over signal groups and run each of them.
            jMax=length(self.signal_group_list);
            for j=1:jMax
                signal_group=self.signal_group_list{j};
                fprintf('Generating data for signal group %s...\n', ...
                    signal_group.signal_name);
                start_time=clock;
                signal_group=self.signal_group_list{j};
                signal_group.run()
                elapsed_time=etime(clock,start_time);
                fprintf('Done. Took %0.2f seconds\n\n',elapsed_time);
            end
            rmpath(self.data_set_root);
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
                }; %#ok<PROP>
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
                signal_group_list=cell(1,jMax); %#ok<PROP>
                for j=1:jMax
                    signal_name=signal_name_list{j};
                    signal_group_list{j}= ...
                        self.signal_group_name_to_instance(signal_name); %#ok<PROP>
                end
            end
            
            %Make sure Charman_tables are generated and loaded
            jMax_signal_group=length(signal_group_list); %#ok<PROP>
            for j=1:jMax_signal_group
                signal_group=signal_group_list{j}; %#ok<PROP>
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
                    signal_group=signal_group_list{1}; %#ok<PROP>
                    S_array=signal_group.extract_S_array();
                    bin_height=zeros(n_bins,jMax_signal_group);
                    bin_uncertainty=zeros(n_bins,jMax_signal_group);
                    [bin_count,bin_center]=hist(S_array,n_bins);
                    bin_height(:,1)=bin_count/sum(bin_count);
                    bin_uncertainty(:,1)=sqrt(bin_count)/sum(bin_count);
                    
                    %Do the rest of the histograms given the bin centers
                    %from above.
                    for j_signal_group=2:jMax_signal_group
                        signal_group=signal_group_list{j_signal_group}; %#ok<PROP>
                        S_array=signal_group.extract_S_array();
                        [bin_count,bin_center]=hist(S_array,n_bins);
                        bin_height(:,j_signal_group)=bin_count/sum(bin_count);
                        bin_uncertainty(:,j_signal_group)=sqrt(bin_count)/sum(bin_count);
                    end
                    
                    %Get names for legend
                    legend_names=cell(1,jMax_signal_group);
                    for j_signal_group=1:jMax_signal_group
                        signal_group=signal_group_list{j_signal_group}; %#ok<PROP>
                        legend_names{j_signal_group}=signal_group.signal_name;
                    end
                    figure('WindowStyle','docked');
                    errorbar([bin_center',bin_center'],bin_height,bin_uncertainty, ...
                        '-s','MarkerSize',4);
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
            
            fprintf('Done.  Took %0.2f seconds\n',toc);
        end
        
        function data_set = get_one_data_set(self)
            %Returns one new Data_Set.  Useful for debugging Data_Set.m
            if isempty(self.signal_group_list)
                msgIdent='Analysis:get_one_data_set:NoSignalGroups';
                msgString='Please add a signal group before requesting a data set';
                error(msgIdent,msgString);
            end
            signal_group=self.signal_group_list{1};
            data_set_list=signal_group.data_set_list;
            %Try to load the data set list if it's empty
            if isempty(data_set_list)
                signal_group.load_data_list();
            end
            data_set_list=signal_group.data_set_list;
            %If it's still empty, generate some data sets
            if isempty(data_set_list)
                self.run();
                data_set_list=signal_group.data_set_list;
            end
            data_set=data_set_list{1};
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
        
        function [name_string] = func_to_signal_name(signal_func)
            %Smartly converts a function handle to a default name string
            name_string=func2str(signal_func);
            name_string=strrep(name_string,'/','<slash>');
            %             name_string=strrep(name_string,'_','<underscore>');
        end
        
        function tracer_file_name = interpret_tracer_name(tracer_name)
            %Returns the file_name of the specified tracer data file with
            %the relative path added.
            %   'all' returns AllSimDataSorted.mat, 'large' returns
            %   LargeSimDataSorted.mat, and medium returns
            %   'MediumSimDataSorted.mat
            if strcmp(tracer_name,'all')
                tracer_name='AllSimDataSorted.mat';
            elseif strcmp(tracer_name,'large')
                tracer_name='LargeSimDataSorted.mat';
            elseif strcmp(tracer_name,'medium')
                tracer_name='MediumSimDataSorted.mat';
            end
            
            %If the given tracer_name does not exist, it is probably just
            %missing the relative path.
            if exist(tracer_name,'file')==2
                tracer_file_name=tracer_name;
            else
                tracer_file_name=fullfile(Analysis.SIMULATION_DATA, ...
                    'TracerOutput', ...
                    tracer_name);
            end
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
            
            %Set some file names
            file_name='tracer_name.mat';
            self.tracer_file_name_file=fullfile(self.data_set_root,file_name);
            file_name='signal_group_list.mat';
            self.signal_group_file_name=fullfile(self.data_set_root,file_name);
        end
        
        function [] = add_position_generator(self)
            %Adds a new position generator.
            
            %Get index of the new generator in self.position_generator_list
            generator_index=length(self.position_generator_list)+1;
            
            %Use generator_index and a random number to seed the
            %position_generator
            next_seed=zeros(1,2);
            next_seed(1)=generator_index;
            next_seed(2)=rand(self.position_generator_seeder);
            position_generator= ...
                Position_Generator(self.tracer_file_name,next_seed);
            self.position_generator_list{generator_index}=position_generator;
        end
        
        function [] = start_parpool(self)
            %Starts up the parallel processing pool and creates
            %Position_Generator instances for the workers.
            if matlabpool('size')==0
                pool_instance=parpool();
            else
                pool_instance=gcp(); %get already running pool
            end
            self.n_workers=pool_instance.NumWorkers;
            self.update_position_generator_list();
        end
        
        function [] = update_position_generator_list(self)
            %Adds or deletes position generators for the parpool workers to
            %set it to self.position_generator_list
            n_generators=length(self.position_generator_list);
            if self.n_workers>n_generators %Need more generators
                jMax=self.n_workers-n_generators;
                for j=1:jMax
                    self.add_position_generator()
                end
            elseif self.n_workers<n_generators %More generators than necessary
                self.position_generator_list= ...
                    self.position_generator_list{1:self.n_workers};
            end
        end
        
        function [] = make_clean(self)
            %Deletes all output data
            
            %First erase signal_data_sets since leaving these around causes
            %the biggest issues
            jMax=length(self.signal_group_list);
            for j=1:jMax
                signal_group=self.signal_group_list{j};
                signal_group.make_clean();
                signal_group.create_directories();
            end
        end
        
        function [] = save_signal_group_list(self)
            %Save self.signal_group_list to the self.data_set_root
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
            if self.signal_group_file_exists()
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
        
        function [] = save_tracer_file_name(self)
            %Save self.tracer_file_name to the self.data_set_root directory
            save_mat(self.tracer_file_name_file,self.tracer_file_name);
        end
        
        function [] = load_tracer_file_name(self)
            %Loads the tracer_file_name from the harddrive
            name_string=load_mat(self.tracer_file_name_file);
            self.set_tracer_file(name_string);
        end
        
        function bool = tracer_file_name_file_exists(self)
            %Checks if there is a saved signal_group_list file
            if exist(self.tracer_file_name_file,'file')==2
                bool=true;
            else
                bool=false;
            end
        end
        
    end %End of hidden methods
    
end

