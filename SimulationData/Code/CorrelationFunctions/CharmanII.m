function [ A_1 ] = CharmanII( date_times, data, period )
%Computes A_1 from data using Charman's method from section II of
%Charman_sinusoid_estimator.pdf.  Best for yearly signals.
%   date_times should be a column vector giving the times of the events.
%   data should be a column vector giving the corresponding data of
%   interest (z-positions of the events).  The data does not need to be sorted
%   before passing it to this function.  If period is 'day', 'lunar', or
%   'year', it will automatically be converted into sidereal days.  The
%   times in data should be given in the format provided by datenum(),
%   which is number of Matlab days since a reference point.  Matlab days
%   are defined as 60.0*60.0*24.0 seconds.  All calculations are done in
%   Matlab days, so the given period is converted from sidereal days to
%   Matlab days.

%Return NaN if data is empty
if isempty(data)
    A_1=NaN;
    return
end

SIDEREAL_DAY=86164.09/(60*60*24); %sidereal day in matlab days

%Intperpret period.  More accurate values for these periods would be
%good to have.
if strcmp(period,'day')
    period=SIDEREAL_DAY; %sidereal day
elseif strcmp(period,'lunar') || strcmp(period,'moon')
    period=27.0*SIDEREAL_DAY; %We'll have to deal with this later
elseif strcmp(period,'year')
    period=31558149.8/(60*60*24); %one sidereal year in Matlab days
end

omega=2*pi/period;

%Compute necessary averages
%p_omega_t implies exp(+i*omega*t), n_omega_t implies exp(-i*omega*t)
%p2_omega_t implies exp(+2*omega*t)
mean_z_p_omega_t=mean( data.*exp(1i*omega*date_times) );
mean_z=mean(data);
mean_p_omega_t=mean( exp(1i*omega*date_times) );
mean_n_omega_t=mean( exp(-1i*omega*date_times) );
mean_p2_omega_t=mean( exp(2i*omega*date_times) );

%Compute C and both Gammas
C=mean_z_p_omega_t-mean_z*mean_p_omega_t;
Gamma_plus_minus=1-mean_n_omega_t*mean_p_omega_t;
Gamma_plus_plus=mean_p2_omega_t-mean_p_omega_t*mean_p_omega_t;

%Compute A_1
numerator=Gamma_plus_minus*C-Gamma_plus_plus*C;
denominator=abs(Gamma_plus_minus)^2-abs(Gamma_plus_plus)^2;
A_1=numerator/denominator;

end