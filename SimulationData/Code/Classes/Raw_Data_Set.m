classdef Raw_Data_Set < handle
    %Stores all the raw data for one data set
    %   Records date times, wait times, and z-positions for left and right
    %   data.
    
    properties (SetAccess = private)
        %Left data
        left_date_times %Wall date/time of left events
        left_z_positions %z-position of left annihilations
        left_charges %charges used for left annihilations
        n_left %Number of quip left data points
        
        %Right data
        right_date_times %Wall date/time of right events
        right_z_positions %z-position of right annihilations
        right_charges %charges used for right annihilations
        n_right %Number of quip right data points
        
        %Other data
        n_events %Number of events
        charges %fractional charges
    end
    
    methods
        
        function self = Raw_Data_Set()
            %Initializes a Raw_Data_Set 
            
        end
        
        function [] = set_date_times(self,date_times,n_left)
            %Sets the left_date_times and right_date_times
            
            %Left data
            self.left_date_times=date_times(1:n_left);
            
            %Right data
            self.right_date_times=date_times((n_left+1):end);
            
            %Set other data
            self.n_left=n_left;
            self.n_events=length(date_times);
            self.n_right=self.n_events-self.n_left;
        end
        
        function [] = set_z_positions(self,z_positions)
            %Sets right_z_positions and left_z_positions
            
            if isempty(self.left_date_times) && isempty(self.right_date_times)
                msgIdent='Raw_Data_Set:set_z_positions:date_times_unset';
                msgString='date_times must be set before z_positions';
                error(msgIdent,msgString);
            end
            
            %Left data
            self.left_z_positions=z_positions(1:self.n_left);
            
            %Right data
            self.right_z_positions=z_positions((self.n_left+1):end);
        end
        
        function [] = set_charges(self,charges)
            %Sets charges
            
            if isempty(self.left_date_times) && isempty(self.right_date_times)
                msgIdent='Raw_Data_Set:set_z_positions:date_times_unset';
                msgString='date_times must be set before z_positions';
                error(msgIdent,msgString);
            end
            
            %Left data
            self.left_charges=charges(1:self.n_left);
            
            %Right data
            self.right_charges=charges((self.n_left+1):end);
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

