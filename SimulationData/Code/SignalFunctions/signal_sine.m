function [] = signal_sine(data_set,z_amplitude,period,phase )
%Adds a sine wave to the data set with the given period and amplitudes
%   z_amplitude gives the amplitude of the sine wave (in meters) added to
%   the z data.  The period can either be the numeric period (in
%   Matlab days), or one of 'day', ' lunar', or 'year'. phase is the
%   angular phase (in radians). phase=0 implies that the sine wave starts
%   at datenum(0).
%   This function applies the signal opposite ways for opposite directions

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

raw_data_set=data_set.raw_data_set;
n_left=data_set.n_left;

left_date_times=raw_data_set.left_date_times;
right_date_times=raw_data_set.right_date_times;

left_z_positions=raw_data_set.left_z_positions;
right_z_positions=raw_data_set.right_z_positions;

%Add signal
left_sine_vals=sin(omega*left_date_times+phase);
left_z_positions=left_z_positions+z_amplitude*left_sine_vals;

right_sine_vals=sin(omega*right_date_times+phase);
right_z_positions=right_z_positions-z_amplitude*right_sine_vals;

%Combine back into a raw data set
top=[ ...
    left_date_times, ...
    left_z_positions, ...
    ];

bottom=[ ...
    right_date_times, ...
    right_z_positions, ...
    ];

%Update data set's raw data set
data_array=[top;bottom];
data_set.create_raw_data_set(data_array,n_left);

end

