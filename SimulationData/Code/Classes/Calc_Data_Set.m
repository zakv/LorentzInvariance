classdef Calc_Data_Set
    %Stores CMB Velocity, moon position, sun position, and any other calculated
    %paramters,
    %   Calculating these takes a while, so it may be useful to just keep
    %   the results stored in an object for a while and then it can be
    %   deleted later to free up RAM or Hard Drive space.
    
    properties (SetAccess = private)
        %CMB velocity
        left_v_x %x-component of CMB velocity
        left_v_y %y-component of CMB velocity
        left_v_z %z-component of CMB velocity
        right_v_x %x-component of CMB velocity
        right_v_y %y-component of CMB velocity
        right_v_z %z-component of CMB velocity
        
        %Moon Position %To be included later
%         left_moon_altitude %moon's angular altitude (degrees)
%         left_moon_azimuth %moon's azimuth (degrees)
%         left_moon_distance  %moon's distance (AU)
%         right_moon_altitude %moon's angular altitude (degrees)
%         right_moon_azimuth %moon's azimuth (degrees)
%         right_moon_distance  %moon's distance (AU)
        
        %Sun Position %To be included later
%         left_sun_altitude %sun's angular altitude (degrees)
%         left_sun_azimuth %sun's azimuth (degrees)
%         left_sun_distance  %sun's distance (AU)    
%         right_sun_altitude %sun's angular altitude (degrees)
%         right_sun_azimuth %sun's azimuth (degrees)
%         right_sun_distance  %sun's distance (AU)       
    end
    
    methods
        function self  = Calc_Data_Set(raw_data_set)
            %Initializes a Calculated_Data_Set
            left_date_times=raw_data_set.left_date_times;
            right_date_times=raw_data_set.right_date_times;
            [self.left_v_x, sefl.left_v_y, self.left_v_z] = ...
                datenum_to_cmb_velocity(left_date_times);
            [self.right_v_x, sefl.right_v_y, self.right_v_z] = ...
                datenum_to_cmb_velocity(right_date_times);
        end
        
        function [v_x,v_y,v_z] = get_velocity(self,direction_index)
            %Returns the CMB velocities in a given direction (1 for loeft
            %or 2 for right).
            if direction_index==1
                v_x=self.left_v_x;
                v_y=self.left_v_y;
                v_z=self.left_v_z;
            elseif direction_index==2
                v_x=self.right_v_x;
                v_y=self.right_v_y;
                v_z=self.right_v_z;
            else
                msgIdent='Calc_Data_Set:get_velocities:InvalidDirection';
                msgString='Direction must be either 1 (for left) or 2 (for right)';
                error(msgIdent,msgString);
            end
        end
    end
    
end

