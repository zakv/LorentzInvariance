function [eventTimes] = generate_event_times_method2(random_generator)
%Generates eventTimes
% 1) decides number of runs - normal distributions ( sigma = rms )
% & number of events oer run - maximum likelihood estimate, Poisson distribution
% 2) decides when the first run ends (poisson) and when the last runs
% ends (normal(gaussian))
% 3) randomly decides the event time


%-------------get experimental data-------------
oldDir = cd('../../../ExperimentalTimeData/Class');
%gets time information
successful = successful_run();
attempted = attempted_run();
shiftCycle = shift_cycle();

successfulEventTime = successful.eventTime('utc','all','all');
shiftCycle = shiftCycle.attempted();
attemptedRunTime = attempted.startTime();
%runTime = attempted.start2end_quench();
cd(oldDir);

%-----------prepare data------------------------
oldDir = cd('../../../ExperimentalTimeData/Code/TimeAnalysisFunction/');
%convert from local time to utc
shiftCycle = st2utc_ch(shiftCycle);
attemptedRunTime = st2utc_ch(attemptedRunTime);
%get the first and last run in a shift
[~,runs_cycle] = calc_events_per_time_cycle(attemptedRunTime,shiftCycle);
cd(oldDir);

n_runs_exp = numel(unique(successfulEventTime));%number of runs (experiment)
n_cycle = length(runs_cycle);%number of shift cycles

%shiftStart_to_firstRun = runs_cycle(:,1) - shiftCycle(:,1);%for estimating parameters
firstRun_to_lastRun = runs_cycle(:,2) - runs_cycle(:,1);

%------------estimate parameters-------------
%probability of getting one Hbar for the run - Poisson process
lambda_n_Hbars=0.387532;%maximum likelihood estimate

%probability of getting successful run in a time
start_estimates_poisson = [0.0058050, 9.3289];
        %fit_shifted_poisson(shiftStart_to_firstRun);

%estimates time from when first run starts to when last run starts using mean
end_estimates_gaussian = [mean(firstRun_to_lastRun), std(firstRun_to_lastRun)];

%time from when run starts to ends; exactly 10 min
run_estimates_gaussian = [10/60/24, 0];
    
%--------1. decides number of runs--------------
%number of runs
rms = sqrt(n_runs_exp);
rand_val = random_generator.rand(1);
n_runs_sim = round(get_normal_dis(rand_val, n_runs_exp, rms));

%------2. decides running time------------------
%when first run ends and last run ends
shiftStart_to_firstRun_sim = zeros(n_cycle,1);
first_runTime = zeros(n_cycle,1);
firstRun_to_lastRun_sim = zeros(n_cycle,1);

for j = 1:n_cycle
    %Calculates time when first run starts in a cycle
    rand_val = random_generator.rand(1);
    shiftStart_to_firstRun_sim(j) = get_occurrence_time(rand_val,...
        start_estimates_poisson(1),start_estimates_poisson(2));
    first_runTime(j) = shiftCycle(j,1) + shiftStart_to_firstRun_sim(j);
    %Calculates time from when first run starts to last run starts
    while firstRun_to_lastRun_sim(j) <=0
        rand_val = random_generator.rand(1);
        firstRun_to_lastRun_sim(j) = get_normal_dis(rand_val,...
            end_estimates_gaussian(1),end_estimates_gaussian(2));
    end
end

totalOperationTime_sim = sum(firstRun_to_lastRun_sim);

%-------3. decides time for each run & number of events----------
%preallocate
eventTimes = zeros(500,1);
n_events_per_run = zeros(n_runs_sim,1);
row_index = 1;

for m = 1:n_runs_sim
    %decides time when run starts within the operation time (relative to the ope time)
    rand_val = random_generator.rand(1);
    runTime_rel = rand_val*totalOperationTime_sim;
    
    %Calculates which cycle the runTime_rel is in
    sum_operationTime = 0;
    operationTime_sim = 0;
    k = 0;  %kth cycle
    while runTime_rel > ( sum_operationTime + operationTime_sim )
        k = k+1;        
        sum_operationTime = sum_operationTime + operationTime_sim ;
        operationTime_sim = firstRun_to_lastRun_sim(k);
    end
    
    %absolute time when run starts
    runStartTime = first_runTime(k) + runTime_rel - sum_operationTime;
    %event time(run starting time + time from when run starts to ends
    rand_val = random_generator.rand(1);
    eventTime = runStartTime + get_normal_dis(rand_val,run_estimates_gaussian(1),run_estimates_gaussian(2));
    %number of events per run
    rand_val = random_generator.rand(1);
    n_events_per_run(m) = get_n_Hbars(rand_val,lambda_n_Hbars);
    %reassign the array of event times
    eventTimes(row_index:row_index+n_events_per_run(m)-1) = eventTime;
    %Prepare for next iteration
    row_index=row_index+n_events_per_run(m);
end

eventTimes = eventTimes(eventTimes~=0);
%n_events = sum(n_events_per_run);%for plotting

%{
%---------for CHECK ---write total number of event % run,and run span------
dispstr = ['total number of run is ',num2str(n_runs_sim),' (experiment:320)'];
disp(dispstr);
dispstr = ['total run span is ',num2str(sum(totalOperationTime_sim)),' (experiment:34.8347)'];
disp(dispstr);
dispstr = ['total number of event time is ',num2str(n_events),' (experiment:386)'];
disp(dispstr);

%----------------plot events time diagram-------------------
oldDir = cd('../../../ExperimentalTimeData/Code/TimeAnalysisFunction/');
f_events_diagram = figure;
plot_time_date(eventTimes,'b');
set_for_time_graph();
cd(oldDir);
saveas(f_events_diagram,'eventTimes_diagram.pdf','pdf');
%}
end

function [time] = get_occurrence_time(rand_val,t_0,time_lambda)
%Use poisson process and rand_val to pick a time. rand_val is the exclusive
% event of the possibility not happening any event at specific time.
time = - log(1 - rand_val)/time_lambda + t_0;
end

function[value] = get_normal_dis(rand_val,mu,std)
value = sqrt(2*std^2)*erfinv(2*rand_val - 1) + mu;
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
    
%{
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
end
%}