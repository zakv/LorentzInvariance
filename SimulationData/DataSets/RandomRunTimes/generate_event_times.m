function [iterationData] = generate_event_times()
%Returns a column vector of event times in UTC.

%METHOD
%**Here, "run" means the one which attempted to trap Hbars.
%Decides time from when shift starts to when first run starts 
%       - poisson (fit the empirical CDF with exponential)
%Decides time from when first run starts to when last run starts
%       - normal distribution (fitting parameter:mean&std)
%Decides number of successful run during the time span 
%       - poissonian (with the restriction that it is greater than zero)
%Decides time of successful run starts
%       - uniform random
%Decides number of events for each successful run
%       - poisson process (fitting parameter:maximum likelihood estimate)
%Decides time from when run starts to ends(assuming this is the event time)
%       - normal distribution (fitting parameter:median%MAD)

%10000iterations
%number of events : 388.6286+_29.0207 (experiment:386)
%number of runs   : 322.1151+_23.1404 (experiment:320)
%total run time   : 29.7177+_1.4017 (experiment:29.6966)

%MEMO: the number or events doesn't change that much even if the parameter of
%estimating when run starts to ends is changed to median.

%-------------get experimental data-------------
oldDir = cd('../../../ExperimentalTimeData/Class');
%gets time information
successful = successful_run();
attempted = attempted_run();
shiftCycle = shift_cycle();

successfulEventTime = successful.eventTime('utc','all','all');%utc
shiftCycle = shiftCycle.attempted();
attemtpedStartTime = attempted.startTime();
runTime = attempted.start2end_quench();
cd(oldDir);

%n_Hbars_experiment = vertcat(1*ones(261,1),2*ones(53,1),3*ones(5,1),4*ones(1,1));
%this data is only for figure

%-----------prepare data------------------------
oldDir = cd('../../../ExperimentalTimeData/Code/TimeAnalysisFunction/');
%change the time from local to utc
shiftCycle = st2utc_ch(shiftCycle);
attemtpedStartTime = st2utc_ch(attemtpedStartTime);
%get the first and last run in a shift
runs_cycle = calc_events_per_time_cycle(attemtpedStartTime,shiftCycle);
cd(oldDir);

shiftStart_to_firstRun = runs_cycle(:,2) - shiftCycle(:,1);
firstRun_to_lastRun = runs_cycle(:,3) - runs_cycle(:,2);
totalRunSpan = sum(firstRun_to_lastRun);
n_successfulRuns = numel(unique(successfulEventTime)); %320

%--------calculates estimetes parameter-------------
%probability of getting one Hbar for the run - Poisson process
n_Hbar_lambda=0.387532;%maximum likelihood estimate

%probability of getting successful run in a time
n_runs_lambda=n_successfulRuns/totalRunSpan;

%estimates time from when shift starts to when firstrun starts
start_estimates_poisson = [0.0058050, 9.3289];
        %fit_shifted_poisson(shiftStart_to_firstRun);
        
%estimates time from when shift starts to when last run starts using mean
end_estimates_gaussian = [mean(firstRun_to_lastRun), std(firstRun_to_lastRun)];

%estimates time from when run starts to when run ends using median
run_estimates_gaussian = [median(runTime), 1.4826*mad(runTime,1)];

%------------generate event times--------------------
eventTimes=zeros(500,1); %Preallocate
row_index=1;
jMax = numel(shiftStart_to_firstRun);
run_index = 0;
n_Hbars = zeros(1000,1);

test_n_runs = zeros(jMax,1);
shiftStart_to_firstRun_sim = zeros(jMax,1);
firstRun_to_lastRun_sim = zeros(jMax,1);

for j=1:jMax
    %T1) calculates time when first run starts
    rand_val = rand(1);
    shiftStart_to_firstRun_sim(j) = get_occurrence_time(rand_val,start_estimates_poisson(1),start_estimates_poisson(2));
    first_runTime = shiftCycle(j,1) + shiftStart_to_firstRun_sim(j);
    %dT) calculates time from when first run starts to when last run starts
    rand_val1 = rand(1);
    rand_val2 = rand(1);
    firstRun_to_lastRun_sim(j) = get_normal_dis(rand_val1,rand_val2,end_estimates_gaussian(1),end_estimates_gaussian(2));
    %number of runs per time dT
    rand_val = rand(1);
    n_runs = get_n_runs(rand_val,firstRun_to_lastRun_sim(j),n_runs_lambda);
    %number of events per each run
    if n_runs >= 1
        for i = 1:n_runs
            run_index = run_index + 1;
            rand_val1 = rand(1);
            rand_val2 = rand(1);
            runStart2End = get_normal_dis(rand_val1,rand_val2,run_estimates_gaussian(1),run_estimates_gaussian(2));
            rand_val = rand(1);
            eventTime = first_runTime + firstRun_to_lastRun_sim(j)*rand_val + runStart2End;
            rand_val = rand(1);
            n_Hbars(run_index) = get_n_Hbars(rand_val,n_Hbar_lambda);
            eventTimes(row_index:row_index+n_Hbars(run_index)-1) = eventTime;
            %Prepare for next iteration
            row_index=row_index+n_Hbars(run_index);
        end
    end
    test_n_runs(j) = n_runs;
end

%Strip unused rows of preallocated array
used_indices=eventTimes~=0;
eventTimes=eventTimes(used_indices);
%used_indices=n_Hbars~=0;
%n_Hbars=n_Hbars(used_indices);

%{
%-------------plot experimental & simulation data --------------------
%plot time from when shift starts to when first run starts
%hist
figure
x = (0:0.05:1);
y1 = hist(shiftStart_to_firstRun,x); 
y2 = hist(shiftStart_to_firstRun_sim,x);
D = [y1;y2];
bar(x,D',1.4);
xlim([0 0.8]);
xlabel('day')
ylabel('count')
legend('experiment','simulation')
title('time from when shift starts to when first run starts');

%plot time from when first run starts to when last run starts
%hist
figure
x = (0:0.020:1);
y1 = hist(firstRun_to_lastRun,x); 
y2 = hist(firstRun_to_lastRun_sim,x);
D = [y1;y2];
bar(x,D',1.4);
xlim([0 0.8]);
xlabel('day')
ylabel('count')
legend('experiment','simulation')
title('time from when first run starts to when last run starts');

%plot number of Hbars per run
figure
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
plot_time_date(eventTimes);
set_for_time_graph();
cd(oldDir);

saveas(f_events_diagram,'eventTimes_diagram.pdf','pdf');

%---------for CHECK ---write total number of event % run,and run span------
dispstr = ['total number of run is ',num2str(sum(test_n_runs)),' (experiment:',num2str(n_successfulRuns),')'];
disp(dispstr);
dispstr = ['total run span is ',num2str(sum(firstRun_to_lastRun_sim)),' (experiment:',num2str(totalRunSpan),')'];
disp(dispstr);
dispstr = ['total number of event time is ',num2str(numel(eventTimes)),' (experiment:',num2str(numel(successfulEventTime)),')'];
disp(dispstr);
%}

%-------for iteration----------
iterationData = [numel(eventTimes),sum(test_n_runs),sum(firstRun_to_lastRun_sim)];
end

function [time] = get_occurrence_time(rand_val,t_0,time_lambda)
%Use poisson process and rand_val to pick a time. rand_val is the exclusive
% event of the possibility not happening any event at specific time.
time = - log(1 - rand_val)/time_lambda + t_0;
end

function [value] = get_normal_dis(rand_val1,rand_val2,mu,std)
%Box-Muller transform. Needs two rands.
rand_norm = sqrt(-2*log(rand_val1))*cos(2*pi*rand_val2);
value = mu + std.*rand_norm;
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

%{
function [estimates] = fit_shifted_poisson(data)
%fits shifted poisson distribution by using probability function
[ydata, xdata] = ecdf(data);
estimates = fitcurve(xdata, ydata);

%{
%empirical CDF
figure
[ydata, xdata] = ecdf(data);
plot(xdata,ydata,'b')
hold on
plot(xdata, 1 - exp( -estimates(2)*(xdata - estimates(1)) ),'r')
ylim([0 1])
xlabel('day')
ylabel('Probability')
legend('experiment','fitting')
%}

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
end
%}