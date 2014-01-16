classdef Signal_Group < handle
    %Records the information about one group of signal data sets
    
    properties (SetAccess=private)
        analysis_parent %Parent analysis instance
        signal_func %Handle to function that adds the signal
        signal_name %Name string for function
        signal_dir %Directory that stores all of the signal data sets
        file_name_string %Name of files with '%d' in place of index (with path)
        n_sets %Number of signal data sets to make
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
            
            %Make its directory.
            if exist(self.signal_dir,'dir')~=7
                mkdir(self.signal_dir);
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
        
        function data_set_list = get_data_set_list(self)
            %Returns a list of the data_sets that should have a signal data
            %set for this signal group (assuming they've been generated).
            data_set_list=self.analysis_parent.data_set_list(1:self.n_sets);
        end
            
    end
    
end

