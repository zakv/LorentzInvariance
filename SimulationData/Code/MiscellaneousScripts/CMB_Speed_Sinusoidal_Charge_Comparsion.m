sun_cmb=0.0012338*299792458.0; %Taken form cmb_velocity.c
times=linspace(datenum(2010,1,1),datenum(2012,1,1),500);
temp_data_set.raw_data_set.left_date_times=times;
temp_data_set.raw_data_set.right_date_times=[]; %Should also try swapping these
speeds=datenum_to_cmb_velocity(times);
charges=signal_sine(temp_data_set,1.0,'year',0.0);
figure('WindowStyle','docked');
%speeds=speeds-sun_cmb; %Center speeds around 0.0
speeds=speeds-mean(speeds);
speeds=speeds/max(speeds); %Normalize speeds and charges for comparison
charges=charges/max(charges);
plot(times,speeds,times,charges);
ylim(1.02*[-1,1]);
datetick('x','mmm yyyy');
legend('Normalized CMB Speed','Normalized Charge');
legend('Location','SouthEast');