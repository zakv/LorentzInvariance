classdef Raw_Data_Set
    %Stores all the raw data for one data set
    %   Records date times, wait times, and z-positions for left and right
    %   data.
    
    properties (SetAccess = private)
        %Left data
        left_date_times %Wall date/time of left events
        left_z_positions %z-position of left annihilations
        n_left %Number of quip left data points
        
        %Right data
        right_date_times %Wall date/time of right events
        right_z_positions %z-position of right annihilations
        n_right %Number of quip right data points
        
        %Other data
        n_events %Number of events
    end
    
    methods
        function self = Raw_Data_Set(data_array,n_left)
            %Initializes a Raw_Data_Set assuming first Analysis.n_left rows
            %are quip left data points.
            %   data_array should have three columns, first should be the
            %   data time, next should be the wait time, and last should be
            %   the z-position data.  n_left should be the number of data
            %   points taken with quip left (all quip left data should
            %   appear before the quip right data);
            
            self.n_left=n_left;
            self.n_events=size(data_array,1);
            self.n_right=self.n_events-self.n_left;
            
            %Left data
            self.left_date_times=data_array(1:n_left,1);
            self.left_z_positions=data_array(1:n_left,2);
            
            %Right data
            self.right_date_times=data_array((n_left+1):end,1);
            self.right_z_positions=data_array((n_left+1):end,2);
        end
        
        function data = get_z_positions(self,direction_index)
            %Returns an array of z-positions for either quip left or quir
            %right, depending on the given direction_index.
            %   1 implies z-positions or quip left
            %   2 implies wait_times or quip right
            if direction_index==1
                data=self.left_z_positions;
            elseif direction_index==2
                data=self.right_z_positions;
            else
                msgIdent='Raw_Data_Set:get_data:IndexOutOfBounds';
                msgString='direction_index must be 1 or 2';
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

