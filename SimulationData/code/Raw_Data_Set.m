classdef Raw_Data_Set
    %Stores all the raw data for one data set
    %   Records date times, wait times, and z-positions for left and right
    %   data.
    
    properties (SetAccess = private)
        %Left data
        left_date_times %Wall date/time of left events
        left_wait_times %Wait times of left events (time between quench and
                        %annihilation in seconds)
        left_z_positions %z-position of left annihilations
        
        %Right data
        right_date_times %Wall date/time of right events
        right_wait_times %Wait times of right events (time between quench
                         %and annihilation in seconds)
        right_z_positions %z-position of right annihilations
    end
    
    methods
        function self = Raw_Data_Set(data_array)
            %Initializes a Raw_Data_Set assuming first Analysis.n_left rows
            %are quip left data points.
            %   data_array should have three columns, first should be the
            %   data time, next should be the wait time, and last should be
            %   the z-position data.  n_left should be the number of data
            %   points taken with quip left (all quip left data should
            %   appear before the quip right data);
            
            n_left=Analysis.N_LEFT;
            
            %Left data
            self.left_date_times=data_array(1:n_left,1);
            self.left_wait_times=data_array(1:n_left,2);
            self.left_z_positions=data_array(1:n_left,3);
            
            %Right data
            self.right_date_times=data_array((n_left+1):end,1);
            self.right_wait_times=data_array((n_left+1):end,2);
            self.right_z_positions=data_array((n_left+1):end,3);
        end
        
        function data = get_data(self,data_index,direction_index)
            %Returns an array of z-positions or wait_times for either quip
            %left or quir right, depending on the given indices
            %   1 implies z-positions or quip left
            %   2 implies wait_times or quip right
            if data_index==1 && direction_index==1
                data=self.left_z_positions;
            elseif data_index==1 && direction_index==2
                data=self.right_z_positions;
            elseif data_index==2 && direction_index==1
                data=self.left_wait_times;
            elseif data_index==2 && direction_index==2
                data=self.right_wait_times;
            else
                msgIdent='Raw_Data_Set:get_data:IndexOutOfBounds';
                msgString='data_index and direction_index must be 1 or 2';
                error(msgIdent,msgString);
            end
        end
        
        function date_times = get_date_times(self,direction_index)
            %Returns an array of date_times for the given direction.
            %  1 corresponds to left, 2 corresponds to right
            if direction_index==1
                date_times=self.left_date_times;
            elseif direction_index==2
                date_times=self.right_date_times;
            else
                msgIdent='Raw_Data_Set:get_date_times:IndexOutOfBounds';
                msgString='direction_index must be 1 or 2';
                error(msgIdent,msgString);
            end
        end
    end
    
end

