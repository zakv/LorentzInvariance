classdef Calc_Data_Set
    %Class to store CMB Velocity, moon position, sun position, and/or any
    %other calculated paramters,
    %   Calculating these takes a while, so it may be useful to just keep
    %   the results stored in an object for a while and then it can be
    %   deleted later to free up RAM or Hard Drive space.
    
    properties (SetAccess = private)
        %CMB velocity (angles in degrees)
        left_speed %Magnitude of CMB velocity
        left_theta_trap %Angle between CMB velocity vector and trap axis
        left_phi_trap %Rotation of CMB velocity about trap axis (phi=0 for zenith)
        right_speed %Magnitude of CMB velocity
        right_theta_trap %Angle between CMB velocity vector and trap axis
        right_phi_trap %Rotation of CMB velocity about trap axis (phi=0 for zenith)
        
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
            [self.left_speed, self.left_theta_trap, self.left_phi_trap] = ...
                datenum_to_cmb_velocity(left_date_times);
            [self.right_speed, self.right_theta_trap, self.right_phi_trap] = ...
                datenum_to_cmb_velocity(right_date_times);
        end
        
        function [speed,theta_trap,phi_trap] = get_velocity(self,direction_index)
            %Returns the CMB velocity parameters in a given direction (1
            %for left or 2 for right).
            %   speed is the speed of the Earth relative to the CMB frame.
            %   theta_trap is the angle between the trap axis and the CMB
            %   velocity vector.  phi is the rotation angle of the CMB
            %   velocity vector about the axis of the trap (phi=0 for the
            %   zenith).
            if direction_index==1
                speed=self.left_speed;
                theta_trap=self.left_theta_trap;
                phi_trap=self.left_phi_trap;
            elseif direction_index==2
                speed=self.right_speed;
                theta_trap=self.right_theta_trap;
                phi_trap=self.right_phi_trap;
            else
                msgIdent='Calc_Data_Set:get_velocity:InvalidDirection';
                msgString='Direction must be either 1 (for left) or 2 (for right)';
                error(msgIdent,msgString);
            end
        end
    end
    
end

