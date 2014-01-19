%Test different time conversion functions
addpath ../../EventTime;
datenum_times=generate_event_times();
nRuns=10;


times=zeros(1,nRuns);

disp('Fumika''s orignal')
for j=1:nRuns
    tic
    UTC_times=st2utc_CH(datenum_times);
    times(j)=toc;
end
disp(min(times))

disp(' ')
display('My Version')
for j=1:nRuns
    tic
    UTC_times=st2utc_CH_fast(datenum_times);
    times(j)=toc;
end
disp(min(times))