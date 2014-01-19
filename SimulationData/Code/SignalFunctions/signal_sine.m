function [ signal_data_set ] = signal_sine( raw_data_set,z_amplitude,t_amplitude,period,phase )
%Adds a sine wave to the data set with the given period and amplitudes
%   z_amplitude gives the amplitude of the sine wave (in meters) added to
%   the z data, and t_amplitude gives the amplitude of the sine wave added
%   to the wait time data.  The period can either be the numeric period (in
%   Matlab days), or one of 'day', ' lunar', or 'year'. phase is the
%   angular phase (in radians). phase=0 implies that the sine wave starts
%   at datenum(0).
%   This function applies the signal the same way regardless of quip
%   direction.

if ischar(period)
    SIDEREAL_DAY=86164.09/(60*60*24); %sidereal day in matlab days
    if strcmp(period,'day')
        period=SIDEREAL_DAY; %sidereal day
    elseif strcmp(period,'lunar') || strcmp(period,'moon')
        period=27.0*SIDEREAL_DAY; %We'll have to deal with this later
    elseif strcmp(period,'year')
        period=31558149.8/(60*60*24); %one sidereal year in Matlab days
    end
end

omega=2*pi/period;

left_date_times=raw_data_set.left_date_times;
right_date_times=raw_data_set.right_date_times;

left_wait_times=raw_data_set.left_wait_times;
right_wait_times=raw_data_set.right_wait_times;

left_z_positions=raw_data_set.left_z_positions;
right_z_positions=raw_data_set.right_z_positions;

%Add signal
left_sine_vals=sin(omega*left_date_times+phase);
left_wait_times=left_wait_times+t_amplitude*left_sine_vals;
left_z_positions=left_z_positions+z_amplitude*left_sine_vals;

right_sine_vals=sin(omega*right_date_times+phase);
right_wait_times=right_wait_times+t_amplitude*right_sine_vals;
right_z_positions=right_z_positions-z_amplitude*right_sine_vals;

%Combine back into a raw data set
top=[ ...
    left_date_times, ...
    left_wait_times, ...
    left_z_positions, ...
    ];

bottom=[ ...
    right_date_times, ...
    right_wait_times, ...
    right_z_positions, ...
    ];
    
signal_data_set=Raw_Data_Set([top;bottom]);

end

