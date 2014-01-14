classdef Data_Set < handle
    %Class to handle creation/saving/loading/analysis of Raw_Data_Sets and
    %Calc_Data_Sets
    
    properties (SetAccess = private)
        %Properties that do vary between instances
        index %Index of Raw_Data_Set and Data_Set
        data_set_root %Where generate_event_times.m is stored
        
        %Raw_Data_Set parameters
        raw_data_set_dir %Where Raw_Data_Set files are saved
        raw_file_name %Name of Raw_Data_Set file
        raw_data_set %For storing the Raw_Data_Set
        
        %Calc_Data_Set parameters
        calc_data_set_dir %Where Calc_Data_Set files are saved
        calc_file_name %Name of Calc_Data_Set file
        calc_data_set %For storing the Calc_Data_Set
    end
    
    methods
        function self = Data_Set(index,data_set_root,raw_data_set_dir, ...
                calc_data_set_dir)
            %Initialize a Data_Set
            self.index=index;
            self.data_set_root=data_set_root;
            self.raw_data_set_dir=raw_data_set_dir;
            self.calc_data_set_dir=calc_data_set_dir;
            
            %Set Raw_Data_Set parameters
            name_string=[Analysis.RAW_DATA_SET_PREFIX, ...
                int2str(self.index),'.mat'];
            self.raw_file_name=fullfile(self.raw_data_set_dir, ...
                name_string);
            self.raw_data_set=[]; %Can be loaded later if needed
            
            %Set Calc_Data_Set parameters
            name_string=[Analysis.CALC_DATA_SET_PREFIX, ...
                int2str(self.index),'.mat'];
            self.calc_file_name=fullfile(self.calc_data_set_dir, ...
                name_string);
            self.calc_data_set=[]; %Can be loaded later if needed
        end
        
        function [] = create_raw_data_set(self,data_array)
            %Creates a Raw_Data_Set instance from data_array
            self.raw_data_set=Raw_Data_Set(data_array);
        end
        
        function [] = create_calc_data_set(self)
            %Creates a Calc_Data_Set instance from the raw_data
            unload_raw_data=false;
            if isempty(self.raw_data_set)
                unload_raw_data=true;
                self.load_raw_data_set()
            end
            self.calc_data_set=Calc_Data_Set(self.raw_data_set);
            if unload_raw_data==true
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
        
        function [] = load_raw_data_set(self)
            %Loads the Raw_Data_Set instance memory
            self.raw_data_set=load_mat(self.raw_file_name);
        end
        
        function [] = load_calc_data_set(self)
            %Loads the Calc_Data_Set instance memory
            self.calc_data_set=load_mat(self.calc_file_name);
        end
        
        function [] = unload_raw_data_set(self)
            %Unloads the Raw_Data_Set instance from RAM
            self.raw_data_set=[];
        end
 
        function [] = unload_calc_data_set(self)
            %Unloads the Calc_Data_Set instance from RAM
            self.calc_data_set=[];
        end
        
        function [] = free_ram(self)
            %Frees RAM by setting deleting the Raw_Data_Set and
            %Calc_Data_Set instances.
            self.unload_raw_data_set();
            self.unload_calc_data_set();
        end

    end
    
end

