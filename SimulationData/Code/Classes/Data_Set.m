classdef Data_Set < handle
    %Class to handle creation/saving/loading/analysis of Raw_Data_Sets and
    %Calc_Data_Sets
    
    properties (SetAccess = private)
        %Properties that do vary between instances
        index %Index of Raw_Data_Set and Data_Set
        analysis_parent %Analysis intance that created this Data_Set instance
        
        %Raw_Data_Set parameters
        raw_file_name %Name of Raw_Data_Set file
        raw_data_set %For storing the Raw_Data_Set
        
        %Calc_Data_Set parameters
        calc_file_name %Name of Calc_Data_Set file
        calc_data_set %For storing the Calc_Data_Set
        
        %Signal_Data_Set parameters
        signal_table %For stoing signal data sets and their meta data.  Row
            %names are func names and the other two columns are a cell
            %containing the signal data set object and a cell containing
            %the file name.  Make sure you get the signal data set object
            %and file name string out of theis cells before using them.
    end
    
    methods
        
        function self = Data_Set(analysis_parent,index)
            %Initialize a Data_Set
            self.analysis_parent=analysis_parent;
            self.index=index;
            
            %Set Raw_Data_Set parameters
            name_string=[Analysis.RAW_DATA_SET_PREFIX, ...
                int2str(self.index),'.mat'];
            self.raw_file_name=fullfile(analysis_parent.raw_data_set_dir, ...
                name_string);
            self.raw_data_set=[]; %Can be loaded later if needed
            
            %Set Calc_Data_Set parameters
            name_string=[Analysis.CALC_DATA_SET_PREFIX, ...
                int2str(self.index),'.mat'];
            self.calc_file_name=fullfile(analysis_parent.calc_data_set_dir, ...
                name_string);
            self.calc_data_set=[]; %Can be loaded later if needed
            
            %Set Signal_Data_Set parameters
            self.signal_table=table();
        end
        
        function [] = set_analysis_parent(self,analysis_parent)
            %Allows changing the value stored for self.analysis_parent.
            %   This is useful because the parent can be set to en empty
            %   array before saving the Data_Set instance, which is nice
            %   because now save_mat won't try to save the parent with each
            %   Data_Set instance.  The analysis_parent can then be reset
            %   after loading it again.
            self.analysis_parent=analysis_parent;
        end
        
        function [] = create_raw_data_set(self,data_array)
            %Creates a Raw_Data_Set instance from data_array
            self.raw_data_set=Raw_Data_Set(data_array);
            self.save_raw_data_set();
            self.unload_raw_data_set();
        end
        
        function [] = create_calc_data_set(self)
            %Creates a Calc_Data_Set instance from the raw_data
            unload_raw_data=false;
            if isempty(self.raw_data_set)
                unload_raw_data=true;
                self.load_raw_data_set()
            end
            self.calc_data_set=Calc_Data_Set(self.raw_data_set);
            self.save_calc_data_set();
            self.unload_calc_data_set();
            if unload_raw_data==true
                self.unload_raw_data_set();
            end
        end
        
        function [] = create_signal_data_set(self,signal_func,signal_name,file_name)
            %Creates a signal data set from the raw data by applying the
            %given signal function
            %   The signal function should take a Raw_Data_Set instance and
            %   return a new Raw_Data_Set instance (Do not modify the input
            %   instance!) with the signal added.
            unload_raw_data_set=false;
            if isempty(self.raw_data_set)
                unload_raw_data_set=true;
                self.load_raw_data_set();
            end
            
            %Generate signal data set and add row to signal_table
            signal_data_set=signal_func(self.raw_data_set);
            signal_data_set={signal_data_set};
            file_name={file_name};
            signal_name={signal_name};
            table_row=table(signal_data_set,file_name,'RowNames',signal_name);
            
            if isempty(self.signal_table)
                self.signal_table=table_row;
            elseif ismember(self.signal_table.Properties.RowNames,signal_name{1})
                self.signal_table(signal_name{1},:)={signal_data_set,file_name};
            else
                self.signal_table=[self.signal_table;table_row];
            end
            
            %Save signal data set and unload it
            self.save_signal_data_set(signal_name);
            self.unload_signal_data_set(signal_name);
            
            if unload_raw_data_set==true
                self.unload_raw_data_set();
            end
            
        end

        function [] = save_raw_data_set(self)
            %Saves the Raw_Data_Set instance
            %   This could be improved later to avoid overwriting saved
            %   files if they already exist.  Maybe accept an optional
            %   additional argument 'overtwrite' which may be true or
            %   false.
            if ~isempty(self.raw_data_set)
                save_mat(self.raw_file_name,self.raw_data_set);
            else
                msgIdent='Data_Set:save_raw_data:DataDoesNotExist';
                msgString='No Raw_Data_Set instance is currently loaded';
                error(msgIdent,msgString);
            end
        end
        
        function [] = save_calc_data_set(self)
            %Saves the Calc_Data_Set instance
            %   This could be improved later to avoid overwriting saved
            %   files if they already exist.  Maybe accept an optional
            %   additional argument 'overtwrite' which may be true or
            %   false.
            if ~isempty(self.calc_data_set)
                save_mat(self.calc_file_name,self.calc_data_set);
            else
                msgIdent='Data_Set:save_calc_data:DataDoesNotExist';
                msgString='No Calc_Data_Set instance is currently loaded';
                error(msgIdent,msgString);
            end
        end        
        
        function [] = save_signal_data_set(self,signal_name)
            %Save the signal data set for the given signal_name
            
            signal_data_set=self.signal_table{signal_name,'signal_data_set'};
            signal_data_set=signal_data_set{1}; %Get the signal data set out of its cell
            file_name=self.signal_table{signal_name,'file_name'};
            file_name=file_name{1}; %Get the file name string out of its cell
            if ~isempty(signal_data_set)
                save_mat(file_name,signal_data_set);
            else
                msgIdent='Data_Set:save_signal_data_set:DataDoesNotExist';
                msgString='The specified Signal_Data_Set instance is not currently loaded';
                error(msgIdent,msgString);
            end
        end
        
        function [] = load_raw_data_set(self)
            %Loads the Raw_Data_Set instance memory
            self.raw_data_set=load_mat(self.raw_file_name);
        end
        
        function [] = load_calc_data_set(self)
            %Loads the Calc_Data_Set instance into memory
            self.calc_data_set=load_mat(self.calc_file_name);
        end
        
        function [] = load_signal_data_set(self,signal_name)
            %Loads the specified signal data set
            file_name=self.signal_table{signal_name,'file_name'};
            file_name=file_name{1}; %Get the file name string out of its cell
            self.signal_table(signal_name,'signal_data_set')={{load_mat(file_name)}};
        end
        
        function [] = unload_raw_data_set(self)
            %Unloads the Raw_Data_Set instance from RAM
            self.raw_data_set=[];
        end
 
        function [] = unload_calc_data_set(self)
            %Unloads the Calc_Data_Set instance from RAM
            self.calc_data_set=[];
        end
        
        function [] = unload_signal_data_set(self,signal_name)
            %Unloads the specified signal data set from RAM
            self.signal_table(signal_name,'signal_data_set')={{[]}};
        end
        
        function [] = unload_signal_data_sets(self)
            %Unloads the signal data set from RAM
            self.signal_table(:,'signal_data_set')={[]};
        end
        
        function [] = free_ram(self)
            %Frees RAM by setting deleting the Raw_Data_Set and
            %Calc_Data_Set instances.
            self.unload_raw_data_set();
            self.unload_calc_data_set();
            self.unload_signal_data_sets();
        end

    end
    
end

