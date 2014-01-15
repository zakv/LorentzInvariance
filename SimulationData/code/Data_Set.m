classdef Data_Set < handle
    %Class to handle creation/saving/loading/analysis of Raw_Data_Sets and
    %Calc_Data_Sets
    
    properties (SetAccess = private)
        %Properties that do vary between instances
        index %Index of Raw_Data_Set and Data_Set
        analysis_parent %Analysis intance that created this Data_Set instance
%         data_set_root %Where generate_event_times.m is stored
        
        %Raw_Data_Set parameters
%         raw_data_set_dir %Where Raw_Data_Set files are saved
        raw_file_name %Name of Raw_Data_Set file
        raw_data_set %For storing the Raw_Data_Set
        
        %Calc_Data_Set parameters
%         calc_data_set_dir %Where Calc_Data_Set files are saved
        calc_file_name %Name of Calc_Data_Set file
        calc_data_set %For storing the Calc_Data_Set
        
        %Signal_Data_Set parameters
%         signal_data_set_root %Directory that contains all the 
            %signal data set directories
%         signal_data_set_dirs %List of directories where 
            %signal data sets are saved
        signal_file_names %List of names of signal data set files
        signal_data_sets %For storing the signal data sets
    end
    
    methods
        
        function self = Data_Set(analysis_parent,index)
            %Initialize a Data_Set
            self.analysis_parent=analysis_parent;
            self.index=index;
%             self.data_set_root=analysis_parent.data_set_root;
%             self.raw_data_set_dir=analysis_parent.raw_data_set_dir;
%             self.calc_data_set_dir=analysis_parent.calc_data_set_dir;
            
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
            self.signal_file_names={};
            self.signal_data_sets={};
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
        
        function [] = create_signal_data_set(self,signal_funcs, ...
                file_name_strings,j_start,j_end)
            %Creates a signal data set from the raw data by applying the
            %given signal function
            %   The signal function should take a Raw_Data_Set instance and
            %   return a new Raw_Data_Set instance (Do not modify the input
            %   instance!) with the signal added.
            
            self.load_raw_data_set();
            self.signal_file_names{j_end}=[]; %Preallocate cells
            self.signal_data_sets{j_end}=[];
            k=1;
            for j=j_start:j_end
                %Take care of file name
                signal_file_name=sprintf(file_name_strings{j},self.index);
                self.signal_file_names{j}=signal_file_name;
                
                %Take care of signal data set
                signal_func=signal_funcs{k};
                self.signal_data_sets{j}=signal_func(self.raw_data_set);
                self.save_signal_data_set(j);
                self.unload_signal_data_set(j);
                k=k+1;
            end
            self.unload_raw_data_set();
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
        
        function [] = save_signal_data_set(self,signal_index)
            %Save a signal data set with the given signal_index
            n_signals=length(self.signal_data_sets);
            if signal_index>n_signals || signal_index<1
                msgIdent='Data_Set:save_signal_data_set:InvalidIndex';
                msgString='The given signal_index is invalid';
                error(msgIdent,msgString)
            end
            
            signal_data_set=self.signal_data_sets{signal_index};
            if ~isempty(signal_data_set)
                save_mat(self.signal_file_names{signal_index},signal_data_set);
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
        
        function [] = load_signal_data_set(self,signal_index)
            %Loads the specified signal data set
            self.signal_data_set_list{signal_index}= ...
                load_mat(self.signal_file_names{signal_index});
        end
        
        function [] = unload_raw_data_set(self)
            %Unloads the Raw_Data_Set instance from RAM
            self.raw_data_set=[];
        end
 
        function [] = unload_calc_data_set(self)
            %Unloads the Calc_Data_Set instance from RAM
            self.calc_data_set=[];
        end
        
        function [] = unload_signal_data_set(self,signal_index)
            %Unloads the specified signal data set from RAM
            self.signal_data_sets{signal_index}=[];
        end
        
        function [] = unload_signal_data_sets(self)
            %Unloads the signal data set from RAM
            self.signal_data_sets(:)={[]};
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

