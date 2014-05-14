oldDir = cd('../../Class/');
successful = successful_run();
eventTime = successful.eventTime('utc','all','all');
cd(oldDir);

%plot
oldDir = cd('../../Code/PlotFunction/');
plot_time_date(eventTime);
set_for_time_graph();
