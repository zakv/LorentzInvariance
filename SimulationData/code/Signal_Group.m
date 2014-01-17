classdef Signal_Group < handle
    %Records the information about one group of signal data sets
    
    properties (SetAccess=private)
        analysis_parent %Parent analysis instance
        signal_func %Handle to function that adds the signal
        signal_name %Name string for function
        signal_dir %Directory that stores all of the signal data sets
        file_name_string %Name of files with '%d' in place of index (with path)
        n_sets %Number of signal data sets to make
        table_dir %Directory where tables are stored
        Charman_table %Results from Andy's algorithms
        Charman_file_name %File name (including relative path)
    end
    
    methods
        
        function self = Signal_Group(analysis_parent,signal_func,signal_name,n_sets)
            %Initializes a signal group
            self.analysis_parent=analysis_parent;
            self.signal_func=signal_func;
            self.signal_name=signal_name;
            self.signal_dir=fullfile(analysis_parent.signal_data_set_root,signal_name);
            name_string=[Analysis.SIGNAL_DATA_SET_PREFIX,'%d.mat'];
            self.file_name_string=fullfile(self.signal_dir,name_string);
            max_sets=length(analysis_parent.data_set_list);
            self.n_sets=min(n_sets,max_sets);
            self.table_dir=fullfile(analysis_parent.table_dir,self.signal_name);
            self.Charman_table=[];
            self.Charman_file_name=fullfile(self.table_dir,'Charman_table.mat');
            
            %Make its directories.
            if exist(self.signal_dir,'dir')~=7
                mkdir(self.signal_dir);
            end
            if exist(self.table_dir,'dir')~=7
                mkdir(self.table_dir);
            end
        end
        
        function [] = set_analysis_parent(self,analysis_parent)
            %Allows changing the value stored for self.analysis_parent.
            %   This is useful because the parent can be set to en empty
            %   array before saving the Signal_Group instance, which is
            %   nice because now save_mat won't try to save the parent with
            %   each Signal_Group instance.  The analysis_parent can then
            %   be reset after loading it again.
            self.analysis_parent=analysis_parent;
        end
        
        function generate_signal_data_set(self,data_set)
            %Generates a signal data set from the given data set.  Runs
            %faster if the raw_data_set is already_loaded
            data_set_index=data_set.index;
            if data_set_index<=self.n_sets
                file_name=sprintf(self.file_name_string,data_set_index);
                if exist(file_name,'file')~=2
                    %Ok, need to make the signal data set.  Time to load
                    %the raw_data_set if necessary
                    unload_raw_data_set=false;
                    if isempty(data_set.raw_data_set)
                        unload_raw_data_set=true;
                        data_set.load_raw_data_set();
                    end
                    data_set.create_signal_data_set(self.signal_func, ...
                        self.signal_name,file_name);
                    if unload_raw_data_set==true
                        data_set.unload_raw_data_set();
                    end
                end
            end
        end
        
        function [] = generate_Charman_table(self)
            %Creates a table with results from the two Charman algorithms
            %for periods of both day and year
            
            %Do not generate table if it already exists and has entries for
            %all the data sets
            if ~isempty(self.Charman_table)
                n_data_sets_done=length( unique(self.Charman_table.data_index) );
                if n_data_sets_done>=self.n_sets
                    return
                end
            end
            
            data_set_list=self.get_data_set_list();
            if isempty(data_set_list)
                msgIdent='Signal_Group:generate_Charman_table:NoDataSets';
                msgString='Please generate and save the signal data sets before ';
                msgString=[msgString,'generating Charman_tables'];
                error(msgIdent,msgString);
            end
            jMax_data_set=length(data_set_list);
            
            fprintf('Generating Charman table for %s... ',self.signal_name);
%             addpath ../../CharmanUltra/
            tic;
            
            close_pool_when_done=0;
            if matlabpool('size')==0
                matlabpool('open');
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
            weighted_average=@Analysis.weighted_average;
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
                                algorithm_chunk{j}=algorithm_name;
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
                            algorithm_chunk{j}=algorithm_name;
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
            
            fprintf('done\n');
            fprintf('Generating Charman table for %s took %0.2f seconds\n',self.signal_name,toc);
        end
        
        function data_set_list = get_data_set_list(self)
            %Returns a list of the data_sets that should have a signal data
            %set for this signal group (assuming they've been generated).
            data_set_list=self.analysis_parent.data_set_list(1:self.n_sets);
        end
        
        function set_n_sets(self,n_sets)
            %Updates self.n_sets and calls
            %analysis_parent.generate_signal_data_sets()
            analysis=self.analysis_parent;
            
            max_sets=length(analysis.data_set_list);
            if max_sets==0
                analysis.load_data_sets();
                max_sets=length(analysis.data_set_list);
            end
            self.n_sets=min(n_sets,max_sets);
            
            analysis.generate_signal_data_sets();
        end
        
        function [] = save_Charman_table(self)
            %Saves the Charman table to the Tables subdirectory
            if ~isempty(self.Charman_table)
                save_mat(self.Charman_file_name,self.Charman_table);
            else
                msgIdent='Signal_Group:save_Charman_table:TableEmpty';
                msgString='Cannot save Charman_table; it is currently empty';
                error(msgIdent,msgString);
            end
        end
        
        function [] = load_Charman_table(self)
            %Loads the Charman table from the Tables subdirectory
            if self.Charman_table_file_exists()
                self.Charman_table=load_mat(self.Charman_file_name);
            else
                msgIdent='Signal_Group:load_Charman_table:NoSavedTable';
                msgString='No Charman_table is saved';
                error(msgIdent,msgString);
            end
        end
            
    end %End methods
    
    methods (Hidden)
        
        function bool = Charman_table_file_exists(self)
            %Returns true or false depending on whether or not the
            %Charman_table file exists
            if exist(self.Charman_file_name,'file')==2
                bool=true;
            else
                bool=false;
            end
        end
        
    end
    
end

