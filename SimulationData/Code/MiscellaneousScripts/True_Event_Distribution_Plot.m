%load('../../DataSets/ExperimentalData/SuccessfulStartingTimeCycleData.mat');
load('Data/eventTime_experiment.mat');
event_times=eventTime_local;
plot_start=datenum('1-Aug-2010');
plot_end=datenum('1-Jan-2012');
n_points=200;
x_points=linspace(plot_start,plot_end,n_points);
addpath('../Mex/')
speeds=datenum_to_cmb_velocity(x_points);
fig=figure('WindowStyle','docked');
hold on
plot(x_points,speeds,'r');
shift_speeds=datenum_to_cmb_velocity(event_times);
data_plot=plot(event_times,shift_speeds,'b+');
hold off
%xlabel('Date');
ylabel('CMB Speed (m/s)');
datetick('x','mmm yyyy');
xlim([plot_start,plot_end]);
%title('Earth CMB Speed');
legend(data_plot,'Events','Location','SouthWest');
%set(legend, 'interpreter', 'latex')

%Save the figure
if exist('plots','dir')~=7
    mkdir plots
end
file_name='plots/True_Event_Distribution';
print(fig,file_name,'-depsc')