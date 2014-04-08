function [eventTimes] = generate_event_times(random_generator)
%running 10000 times:
%number of events 391.9361+-26.3308
%number of runs   323.484+-20.5068
%time span        35.0812+-1.0816
%
%[Experiment]
%eventN=386, runN=320, runSpan=34.8347

%Returns a column vector of event times in UTC time chosen to be Poisson or
%Gaussian.
%distributed over the estimated times during which the experiment was
%running.  The number of events per detection is also assumed to be
%Poissonian (with the restriction that it is greater than or equal to zero).

%METHOD
%when shift starts to when actual run starts - poisson (exp for empirical)
%when shift starts to when actual run ends - normal distribution
%   -> time between first actual run and last actual run
% decide number of successful run during the time span - poisson
% decide time of successful run - random
% decide number of events for each successful run - poisson


%-------------get experimental data-------------
oldDir = cd('../../../ExperimentalTimeData/Code/TimeAnalysisFunction');
%gets time information
t = event_time();
shiftCycle = t.shiftCycle();
shiftCycle = st2utc_ch(shiftCycle);% to utc
attemptedRunTime = t.attemptedSpillLogEntryTime();
attemptedRunTime = st2utc_ch(attemptedRunTime);% to utc
successfulEventTime = t.utc('all','all',0);

%prepare data
runs_cycle = calc_events_per_time_cycle(attemptedRunTime,shiftCycle);
totalRunSpan = calc_total_time_of_cycles(runs_cycle(:,2:3));
cd(oldDir);

n_successfulEvents = numel(unique(successfulEventTime)); %320
shiftStart_to_firstRun = runs_cycle(:,2) - shiftCycle(:,1);
shiftStart_to_lastRun = runs_cycle(:,3) - shiftCycle(:,1);

%--------calculates estimetes-----------------
%Poisson process
n_Hbar_lambda=lambda_event_number();%n_successfulEvents/n_attemptedRuns;
n_runs_lambda=n_successfulEvents/totalRunSpan;%successful events/attempted runs
%exponential distribution
start_estimates_poisson = fit_shifted_poisson(shiftStart_to_firstRun);
%least square method for Gaussian
end_estimates_simple = [mean(shiftStart_to_lastRun),std(shiftStart_to_lastRun)];
end_estimates_gaussian = fit_gaussian(shiftStart_to_lastRun);
%disp(end_estimates_gaussian)

%------------generate event times--------------------
eventTimes=zeros(500,1); %Preallocate
row_index=1;
jMax = numel(shiftStart_to_firstRun);
run_index = 0;
n_Hbars = zeros(1000,1);

test_n_runs = zeros(jMax,1);
test_runSpan = zeros(jMax,1);
shiftStart_to_firstRun_sim = zeros(jMax,1);
shiftStart_to_lastRun_sim = zeros(jMax,1);
shiftStart_to_lastRun_simple = zeros(jMax,1);
for j=1:jMax
    %for check
    rand_val1 = random_generator.rand(1);
    rand_val2 = random_generator.rand(1);
    shiftStart_to_lastRun_simple(j) = get_normal_dis_time(rand_val1,rand_val2,end_estimates_simple(1),end_estimates_simple(2));
    %T1) calculates time when first run ends
    rand_val = random_generator.rand(1);
    shiftStart_to_firstRun_sim(j) = get_occurrence_time(rand_val,start_estimates_poisson(1),start_estimates_poisson(2));
    first_runTime = shiftCycle(j,1) + shiftStart_to_firstRun_sim(j);
    %T2) calculates time when last run ends
    rand_val1 = random_generator.rand(1);
    rand_val2 = random_generator.rand(1);
    shiftStart_to_lastRun_sim(j) = get_normal_dis_time(rand_val1,rand_val2,end_estimates_gaussian(1),end_estimates_gaussian(2));
    last_runTime = shiftCycle(j,1) + shiftStart_to_lastRun_sim(j);
    %time : T2-T1
    runSpan = last_runTime - first_runTime;
    %number of runs per time(T2-T1)
    rand_val = random_generator.rand(1);
    n_runs = get_n_runs(rand_val,runSpan,n_runs_lambda);
    %number of events per each run
    if runSpan > 0 && n_runs >= 1
        for i = 1:n_runs
            run_index = run_index + 1;
            rand_val = random_generator.rand(1);
            eventTime = first_runTime + runSpan*rand_val;
            rand_val = random_generator.rand(1);
            n_Hbars(run_index) = get_n_Hbars(rand_val,n_Hbar_lambda);
            eventTimes(row_index:row_index+n_Hbars(run_index)-1) = eventTime;
            %Prepare for next iteration
            row_index=row_index+n_Hbars(run_index);
        end
    end
    test_n_runs(j) = n_runs;
    test_runSpan(j) = runSpan;
end

%Strip unused rows of preallocated array
used_indices=eventTimes~=0;
eventTimes=eventTimes(used_indices);
used_indices=n_Hbars~=0;
n_Hbars=n_Hbars(used_indices);


%-------------plot experimental & simulation data --------------------
%plot time from when first run starts to when last run ends
%hist
f_first_hist = figure;
x = (0:0.05:1);
y1 = hist(shiftStart_to_firstRun,x); 
y2 = hist(shiftStart_to_firstRun_sim,x);
D = [y1;y2];
bar(x,D',1.4);
xlim([0 0.8]);
xlabel('day')
ylabel('count')
legend('experiment','simulation')
title('time from when first run starts to when last run ends');
%empirical CDF
f_first_plot = figure;
[ydata, xdata] = ecdf(shiftStart_to_firstRun);
plot(xdata,ydata,'b')
hold on
plot(xdata, 1 - exp( -start_estimates_poisson(2)*(xdata - start_estimates_poisson(1)) ),'r')
ylim([0 1])
xlabel('day')
ylabel('Probability')
legend('experiment','simulation')


%plot time from when shift starts to when last run ends
%hist
f_end_hist = figure;
x = (0:0.05:1);
y1 = hist(shiftStart_to_lastRun,x); 
y2 = hist(shiftStart_to_lastRun_sim,x);
%y3 = hist(shiftStart_to_lastRun_simple,x);
D = [y1;y2];%[y1;y2;y3];
bar(x,D',1.4);
xlim([0 0.8]);
xlabel('day')
ylabel('count')
legend('experiment','simulation')
title('time from when shift starts to when last run ends');
%empirical CDF
f_end_plot = figure;
[y_ecdf, x_ecdf] = ecdf(shiftStart_to_lastRun);
%cdfdata = normcdf(x,end_estimates_simple(1),end_estimates_simple(2));
cdfdata_ls = normcdf(x,end_estimates_gaussian(1),end_estimates_gaussian(2));
plot(x_ecdf,y_ecdf,'b')
%hold on
%plot(x,cdfdata,'g')
hold on
plot(x,cdfdata_ls,'r')
xlim([0 0.8]);
xlabel('day')
ylabel('Probability')
legend('experiment','estimates using least squares method')

%plot number of Hbars per run
f_nHbar_hist = figure;
n_Hbars_experiment = vertcat(1*ones(261,1),2*ones(53,1),3*ones(5,1),4*ones(1,1));
x = (1:1:max(max(n_Hbars),4));
y1 = hist(n_Hbars_experiment,x);
y2 = hist(n_Hbars,x);
D = [y1;y2];
bar(x,D',1.4);
xlabel('number of events per run');
ylabel('count');
legend('experiment','simulation');

%plot events time diagram
oldDir = cd('../../../ExperimentalTimeData/Code/TimeAnalysisFunction/');
f_events_diagram = figure;
plot_time_from_0am(eventTimes);
set_for_time_graph();
cd(oldDir);

saveas(f_first_hist,'first_hist.pdf','pdf');
saveas(f_first_plot,'first_plot.pdf','pdf');
saveas(f_end_hist,'end_hist.pdf','pdf');
saveas(f_end_plot,'end_plot.pdf','pdf');
saveas(f_nHbar_hist,'nHbar_hist.pdf','pdf');
saveas(f_events_diagram,'eventTimes_diagram.pdf','pdf');

%---------for CHECK ---write total number of event % run,and run span------
dispstr = ['total number of run is ',num2str(sum(test_n_runs)),' (experiment:320)'];
disp(dispstr);
dispstr = ['total run span is ',num2str(sum(test_runSpan)),' (experiment:34.8347)'];
disp(dispstr);
dispstr = ['total number of event time is ',num2str(numel(eventTimes)),' (experiment:386)'];
disp(dispstr);

end

function [time] = get_occurrence_time(rand_val,t_0,time_lambda)
%Use poisson process and rand_val to pick a time. rand_val is the exclusive
% event of the possibility not happening any event at specific time.
time = - log(1 - rand_val)/time_lambda + t_0;
end

function [time] = get_normal_dis_time(rand_val1,rand_val2,mu,std)
%Box-Muller transform. Needs two rands.
rand_norm = sqrt(-2*log(rand_val1))*cos(2*pi*rand_val2);
time = mu + std.*rand_norm;
end

function [n_Hbars] = get_n_Hbars(rand_val,n_Hbar_lambda)
%Gives the number of Hbars in a given trapping run.

%n_Hbars>=1
probability=@(n)n_Hbar_lambda^n*exp(-n_Hbar_lambda)/factorial(n);
    %Probability of getting n events
probability_0=probability(0); %Probability of getting 0 events
rand_val_scaled=(1-probability_0)*rand_val+probability_0;
    %Scale rand_val so that we get at least one Hbar
n_Hbars=0;
running_probability=probability_0;
while running_probability<rand_val_scaled
    n_Hbars=n_Hbars+1;
    running_probability=running_probability+probability(n_Hbars);
end
end

function[n_Runs] = get_n_runs(rand_val,timeSpan,lambda)
%Decides number of events per the timeSpan in case of lambda
%
%rand_val : randumb number
%timeSpan : time
%lambda : mean of number of runs per unit time

probability=@(n) (lambda*timeSpan)^n*exp(-lambda*timeSpan)/factorial(n);

n_Runs=0;
p_sum = probability(0);

while p_sum < rand_val
    n_Runs = n_Runs+1;
    p_sum = p_sum + probability(n_Runs);
end
end

function [mu] = lambda_event_number()
 %Poisson estimate for number of events per run including about 651 +-12
 % unsuccessful trials predicted. 386 events(320 runs) occured.
    iterationNumber = 100000;
    failed_runN = 651;
    failed_runN_std = 12;
    successful_eventN = 386; %old version:312 
    successful_runN = 320; %old version:264
    %eventN_0 = 651 + 12.*randn(iterationNumber,1);
    %lambda = 312./(eventN_0 + 264);
    eventN_0 = failed_runN + failed_runN_std.*randn(iterationNumber,1);
    lambda = successful_eventN./(eventN_0 + successful_runN);
    mu = mean(lambda);
    %sigma = std(lambda);
end

function [estimates] = fit_shifted_poisson(data)
%fits shifted poisson distribution by using probability function
[ydata, xdata] = ecdf(data);
estimates = fitcurve(xdata, ydata);

    function [estimates] = fitcurve(xdata, ydata)
    % Call fminsearch with a random starting point.
    start_point = rand(1, 2);
    model = @expfun;
    estimates = fminsearch(model, start_point);
    % expfun accepts curve parameters as inputs, and outputs sse,
    % the sum of squares error for exp(-lambda * (xdata - x_0) - ydata, 
    % and the FittedCurve. FMINSEARCH only needs sse, but we want to 
    % plot the FittedCurve at the end.
        function [sse, FittedCurve] = expfun(params)
            x_0 = params(1);
            lambda = abs(params(2));
            FittedCurve = 1 - exp(-lambda * (xdata - x_0));
            ErrorVector = FittedCurve - ydata;
            sse = sum(ErrorVector .^ 2);
        end
    end
%-------for iteration----------
%    fprintf(fileID,'%d %d
%    %.8f\n',numel(eventTimes),sum(test_n_runs),sum(test_runSpan));
end

function [estimates] = fit_gaussian(data)
%get estimetes mu, sigma of gaussian distribution by fitting the empirical
%cdf
[ydata, xdata] = ecdf(data);
estimates = abs(fitcurve(xdata, ydata));

    function [estimates] = fitcurve(xdata, ydata)
    % Call fminsearch with a random starting point.
    start_point = rand(1, 2);
    model = @erffun;
    estimates = fminsearch(model, start_point);
    % erffun accepts curve parameters as inputs, and outputs sse,
    % the sum of squares error for 0.5*(1+erf((xdata-mu)/sqrt(2*sigma^2))) - ydata, 
    % and the FittedCurve. FMINSEARCH only needs sse, but we want to 
    % plot the FittedCurve at the end.
        function [sse, FittedCurve] = erffun(params)
            mu = params(1);
            sigma = params(2);
            FittedCurve = 0.5*(1+erf((xdata-mu)/sqrt(2*sigma^2)));
            ErrorVector = FittedCurve - ydata;
            sse = sum(ErrorVector .^ 2);
        end
    end
end