classdef Signal_Group < handle
    %Records the information about one group of signal data sets
    
    properties (SetAccess=private)
        analysis_parent %Parent analysis instance
        signal_func %Handle to function that adds the signal
        signal_name %Name string for function
        file_name_string %Name of data set files with '%d' in place of index (with path)
        n_sets %Number of signal data sets to make
        data_set_list %List of Data_Set objects
        Charman_table %Results from Andy's algorithms
        Charman_file_name %File name (including relative path)
        
        %Directories
        signal_dir %Root directory for the signal group's data
        data_set_dir %Directory where all the data sets are stored
        raw_data_set_dir %Directory where all the Raw_Data_Sets are stored
        calc_data_set_dir %Directory where all the Calc_Data_Sets are stored
        table_dir %Directory where tables are stored
    end
    
    methods
        
        function self = Signal_Group(analysis_parent,signal_func,signal_name,n_sets)
            %Initializes a signal group
            self.analysis_parent=analysis_parent;
            self.signal_func=signal_func;
            self.signal_name=signal_name;
            self.set_n_sets(n_sets);
            
            %Directories
            self.signal_dir=fullfile(analysis_parent.data_set_root,signal_name);
            self.data_set_dir=fullfile(self.signal_dir,'DataSets');
            self.raw_data_set_dir=fullfile(self.signal_dir,'RawDataSets');
            self.calc_data_set_dir=fullfile(self.signal_dir,'CalcDataSets');
            self.table_dir=fullfile(self.signal_dir,'Tables');
            self.create_directories();
            
            name_string=[Analysis.DATA_SET_PREFIX,'%d.mat'];
            self.file_name_string=fullfile(self.signal_dir,name_string);
            self.data_set_list={};
            self.Charman_table=table();
            self.Charman_file_name=fullfile(self.table_dir,'Charman_table.mat');
        end
        
        function [] = run(self)
            %Creates data sets, raw data sets, signal data sets, and
            %Charman tables.
            
            %Check if already generated; return if necessary
            if self.is_generated()
                fprintf('Already fully generated\n');
                return
            end
            
            n_workers=self.analysis_parent.n_workers;
            position_generator_list=self.analysis_parent.position_generator_list;
            all_indices=1:self.n_sets; %All the data_set indices
            indices_chunks=Signal_Group.divvy_up_array(all_indices,n_workers);
            spmd
                data_set_indices_chunk=indices_chunks{labindex};
                position_generator=position_generator_list{labindex};
                random_generator=position_generator.random_generator;
                Charman_rows=cell(1,length(data_set_indices_chunk));
                j_Charman_row=1;
                for j_data_set_index=data_set_indices_chunk
                    %Initialize data set
                    data_set=Data_Set(self,j_data_set_index);
                    
                    %Create raw data set and calc data set
                    %get date times
                    [date_times,n_left]=generate_event_times(random_generator);
                    n_events=length(date_times);
                    %get z-positions
                    z_positions=position_generator.generate_z_positions(n_events);
                    data_array=[date_times,z_positions];
                    data_set.create_raw_data_set(data_array,n_left);
                    data_set.create_calc_data_set();
                    
                    %add signal
                    self.signal_func(data_set);
                    
                    %Create row for Charman table
                    data_set_index=j_data_set_index*ones(3,1);
                    direction=categorical({'left';'right';'averaged'});
                    A_1=zeros(3,1);
                    abs_A_1=zeros(3,1);
                    
                    for j_direction=1:2
                        date_times=data_set.raw_data_set.get_date_times(j_direction);
                        data=data_set.raw_data_set.get_z_positions(j_direction);
                        A_1(j_direction)=CharmanIV(date_times,data,'day');
                        abs_A_1(j_direction)=abs( A_1(j_direction) );
                    end
                    A_1(3)=data_set.weighted_average(A_1(1),A_1(2));
                    abs_A_1(3)=data_set.weighted_average(abs_A_1(1),abs_A_1(2));
                    Charman_rows{j_Charman_row}= ...
                        table(data_set_index,direction,A_1,abs_A_1);
                    
                    %Unload raw data set and calc data set
                    data_set.unload_raw_data_set();
                    data_set.unload_calc_data_set();
                    self.save_data_set(data_set);
                    %                 self.data_set_list{j_data_set_index}=data_set;
                    j_Charman_row=j_Charman_row+1;
                end
                Charman_chunks=vertcat(Charman_rows{:});
            end %End spmd
            
            %Synchronize analysis parent random generators.
            self.analysis_parent.sync_position_generator_list(position_generator(:)');
            
            %Assemble and save Charman_table
            Charman_table=vertcat(Charman_chunks{:}); %#ok<PROP>
            Charman_table.direction=categorical(Charman_table.direction); %#ok<PROP>
            self.Charman_table=Charman_table; %#ok<PROP>
            self.save_Charman_table();
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
        
        function [] = load_data_set_list(self)
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
                    data_set.set_signal_parent(self);
                    self.data_set_list{j}=data_set;
                    indices(j)=data_set.index;
                end
                [~,order]=sort(indices);
                self.data_set_list=self.data_set_list(order);
            end
            disp('Finished loading data sets');
            fprintf('Loading data sets took %0.2f seconds\n',toc);
        end
        
        function set_n_sets(self,n_sets)
            %Figures out value to assign to self.n_sets from the given
            %argument.  If n_sets is 0, it uses a default value
            
            %Set default value if n_sets==0
            if n_sets==0
                n_sets=100;
            end
            
            %Make n_sets isn't too large and return
            self.n_sets=n_sets;
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
        
        function [bool] = is_generated(self)
            %Boolean tells whether or not the data sets, raw data sets,
            %calc data sets, and Charman table exist
            bool=true;
            
            name_string=[Analysis.DATA_SET_PREFIX,'*.mat'];
            file_name_regex=fullfile(self.data_set_dir,name_string);
            file_obj_list=dir(file_name_regex);
            n_data_sets=length(file_obj_list);
            
            name_string=[Analysis.RAW_DATA_SET_PREFIX,'*.mat'];
            file_name_regex=fullfile(self.raw_data_set_dir,name_string);
            file_obj_list=dir(file_name_regex);
            n_raw_data_sets=length(file_obj_list);
            
            name_string=[Analysis.CALC_DATA_SET_PREFIX,'*.mat'];
            file_name_regex=fullfile(self.calc_data_set_dir,name_string);
            file_obj_list=dir(file_name_regex);
            n_calc_data_sets=length(file_obj_list);
            
            n_array=[n_data_sets,n_raw_data_sets,n_calc_data_sets];
            min_n=min(n_array);
            if min_n<self.n_sets
                bool=false;
            end
            
            if self.Charman_table_file_exists()==false
                bool=false;
            end
            
        end
        
    end %End methods
    
    methods (Hidden)
        
        function [] = create_directories(self)
            %Create directories for storing the signal group's data if they
            %do not already exist
            dir_list={ ...
                self.signal_dir, ...
                self.data_set_dir, ...
                self.raw_data_set_dir, ...
                self.calc_data_set_dir, ...
                self.table_dir, ...
                };
            jMax=length(dir_list);
            for j=1:jMax
                directory=dir_list{j};
                if exist(directory,'dir')~=7
                    mkdir(directory);
                end
            end
        end
        
        function [] = save_data_set(self,data_set)
            %Saves a Data_Set object
            if isempty(data_set.raw_data_set) && isempty(data_set.calc_data_set)
                data_set.set_signal_parent([]); %So save_mat doesn't save the parent as well
                OUTPUT_FILE_ROOT=fullfile(self.data_set_dir, ...
                    Analysis.DATA_SET_PREFIX);
                index=data_set.index;
                out_file_name=strcat(OUTPUT_FILE_ROOT,int2str(index),'.mat');
                save_mat(out_file_name,data_set);
                data_set.set_signal_parent(self);
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
        
        function [] = save_Charman_table(self)
            %Saves the Charman table to the Tables subdirectory
            
            %Recreate Charman_table directory if it has been deleted
            if exist(self.table_dir,'dir')~=7
                mkdir(self.table_dir);
            end
            
            %Save it.  Error out if it's empty so that we won't overwrite a
            %full one on accident
            if ~isempty(self.Charman_table)
                save_mat(self.Charman_file_name,self.Charman_table);
            else
                msgIdent='Signal_Group:save_Charman_table:TableEmpty';
                msgString='Cannot save Charman_table; it is currently empty';
                error(msgIdent,msgString);
            end
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
        
        function S_array = extract_S_array(self)
            %Helper function used by generate_Charman_histograms
            filtered_table=filter_table(self.Charman_table,'direction','averaged');
            S_array=filtered_table.abs_A_1;
        end
        
        function delete_Charman_table(self)
            %Deteletes the Charman table.
            self.Charman_table=table();
        end
        
        function [] = make_clean(self)
            %Deletes all data for this signal group
            if exist(self.signal_dir,'dir')==7
                rmdir(self.signal_dir,'s')
                mkdir(self.signal_dir);
            end
            self.create_directories();
            self.data_set_list={};
            self.delete_Charman_table();
        end
        
    end
    
    methods (Hidden, Static)
        
        function chunks = divvy_up_array(data,n_chunks)
            %Returns a cell array of n_workers vectors, each of which is the
            %same size (+/-1)
            n_points=length(data);
            chunks=cell(1,n_chunks);
            chunk_size=floor(n_points/n_chunks);
            remainder=mod(n_points,n_chunks);
            j_left=1;
            j_right=j_left+chunk_size;
            for j=1:n_chunks
                if j<=remainder
                    j_right=j_right+1;
                end
                if j_left<j_right
                    %Add chunk
                    chunks{j}=data(j_left:j_right-1);
                elseif j_left==j_right
                    %Out of data to divvy up
                    chunks{j}=[];
                end
                j_left=j_right;
                j_right=j_right+chunk_size;
            end
        end
        
    end %End Hidden Static methods
    
end

