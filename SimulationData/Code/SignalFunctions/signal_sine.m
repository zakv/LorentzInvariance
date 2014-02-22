function charges = signal_sine(data_set,amplitude,period,phase )
%Charges chosen to be a sine wave with the given period and amplitudes
%   The amplitude is the fractional charge of the Hbar.  The period can
%   either be the numeric period (in Matlab days), or one of 'day', '
%   lunar', or 'year'. phase is the angular phase (in radians). phase=0
%   implies that the sine wave starts at datenum(0)

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

left_date_times=raw_data_set.left_date_times;
right_date_times=raw_data_set.right_date_times;

%Add signal
left_sine_vals=sin(omega*left_date_times+phase);
left_charges=amplitude*left_sine_vals;

right_sine_vals=sin(omega*right_date_times+phase);
right_charges=amplitude*right_sine_vals;

charges=[left_charges;right_charges];

end

