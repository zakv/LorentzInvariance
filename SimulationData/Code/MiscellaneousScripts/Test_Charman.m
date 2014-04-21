%This script is intended to be used to test CharmanII.m and CharmanIV.m.
%It creates a sine wave with the parameters specified below, then fits to
%it and plots the results.

%Parameters that may be worth adjusting
amplitude=1.0;
phase=0.36; %radians
period=31558149.8/(60*60*24); %'year'
n_points=500;

%Code to produce plots
omega=2*pi/period;
start_date=datenum(2010,1,1);
times=linspace(start_date,start_date+period,500); %Integer number of periods
times=transpose(times);
temp_data_set.raw_data_set.left_date_times=times;
temp_data_set.raw_data_set.right_date_times=[];
y_vals=signal_sine(temp_data_set,amplitude,period,phase);
%y_vals=datenum_to_cmb_velocity(times); %Used for figuring out how to adjust phase from CharmanII/IV
%y_vals=y_vals-mean(y_vals);

A_1=CharmanIV(times,y_vals,period);
fit_amplitude=abs(A_1);
fit_phase=angle(A_1);
fit_phase=fit_phase-pi/2; %Fits a cosine wave, this phase shifts it to a sine wave

fit_y_vals=fit_amplitude*sin(omega*times-fit_phase);
%The following doesn't work due to the difference in phase reference for
%the fit_phase and the given phase.  The given phase is relative to a sine
%wave in phase with the CMB speed, while the returned phase is relative to
%a cosine wave starting at datenum(0).
%fit_y_vals=signal_sine(temp_data_set,fit_amplitude,period,fit_phase);
figure('WindowStyle','docked');
hold on
plot(times,y_vals,'b');
plot(times,fit_y_vals,'r-.');
hold off
%datetick('x','mmm yyyy');
legend('Input','Fit');
legend('Location','SouthEast');
amplitude_error=(fit_amplitude-amplitude)/amplitude;
phase_error=(fit_phase-phase)/phase;
fprintf('Amplitude fractional error: %0.2e\n',amplitude_error);
fprintf('Phase fractional error: %0.2e\n',phase_error);