function charges = signal_sine(data_set,amplitude,period,phase )
%Charges chosen to be a sine wave with the given period and amplitudes
%   The amplitude is the fractional charge of the Hbar.  The period can
%   either be the numeric period (in Matlab days), or one of 'day', '
%   lunar', or 'year'. phase is the angular phase (in radians).  Choosing
%   phase=0 puts the wave in phase with the CMB.  Note that this is
%   different from the phase returned by CharmanII/IV, which gives the
%   phase relative to a cosine wave starting at datenum(0).  Also note that
%   the CMB speed does not vary exactly sinusoidally in time, so this is
%   not perfect.  However, it is quite nearly a sinusoidal variation (see
%   CMB_Speed_Sinusoidal_Charge_Comparison.m).

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

%Subtracting this value alligns the phases of the charge variations and CMB Speed
left_date_times=raw_data_set.left_date_times-7.343935490981964e+05;
right_date_times=raw_data_set.right_date_times-7.343935490981964e+05;

%Add signal
left_sine_vals=sin(omega*left_date_times-phase);
left_charges=amplitude*left_sine_vals;

right_sine_vals=sin(omega*right_date_times-phase);
right_charges=amplitude*right_sine_vals;

charges=[left_charges;right_charges];

end