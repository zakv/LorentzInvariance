%Plots Earth's CMB Speed and then plots the phase=0 sinusoidal charge
%signal on the same graph.  Both are normalized and shifted to oscillate
%around 0 for easy comparison.

sun_cmb=0.0012338*299792458.0; %Taken form cmb_velocity.c
sidereal_year=31558149.8/(60*60*24);  %Taken from signal_sine.m
start_date=datenum(2010,1,1);
times=linspace(start_date,start_date+sidereal_year,500); %Integer number of periods
%So that substracting the mean centers the data around y=0
temp_data_set.raw_data_set.left_date_times=times;
temp_data_set.raw_data_set.right_date_times=[]; %Should also try swapping these
speeds=datenum_to_cmb_velocity(times);
charges=signal_sine(temp_data_set,1.0,'year',0.0);
figure('WindowStyle','docked');
%speeds=speeds-sun_cmb; %Center speeds around 0.0
speeds=speeds-mean(speeds);
speeds=speeds/max(speeds); %Normalize speeds and charges for comparison
charges=charges/max(charges);
hold on
plot(times,speeds,'b');
plot(times,charges,'r-.');
hold off
ylim(1.02*[-1,1]);
datetick('x','mmm yyyy');
legend('Normalized CMB Speed','Normalized Charge');
legend('Location','SouthEast');