function [ A_1 ] = CharmanIV( date_times, data, period )
%Computes A_1 from data using Charman's method from section IV of
%Charman_sinusoid_estimator.pdf.  Best for daily signals.
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

%Get times modulo period
date_times=mod(date_times,period);
combined_array=[date_times,data];

%Sort the array
combined_array=sortrows(combined_array);

%Separate t and z data to make code simpler to read and get y_data
date_times=combined_array(1:end,1);
data_array=combined_array(1:end,2);
y_data=data_array.*exp(1i*omega*date_times);

%Use trapezoid rule (and include portion from wrapping around the
%period)
n_events=length(y_data);
if n_events>1
    running_sum=trapz(date_times,y_data);
    running_sum=running_sum + ...
        0.5*(y_data(1)+y_data(end)) * ( period-(date_times(end)-date_times(1)) );
    A_1=running_sum/period;
elseif n_events==0
    A_1=NaN;
end

end