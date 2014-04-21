function [n_events] = generate_event_times_newMethod(random_generator)
%Generates eventTimes
% 1) decides number of runs - normal distributions ( sigma = rms )
% & number of events oer run - maximum likelihood estimate, Poisson distribution
% 2) decides when the first run ends (poisson) and when the last runs
% ends (normal(gaussian))
% 3) randomly decides the event time

%number of events : 386.07 for 4579 iterations

%-------------get experimental data-------------
oldDir = cd('../../../ExperimentalTimeData/Code/TimeAnalysisFunction');
%gets time information
t = event_time();
shift_cycle = t.shiftCycle();
shift_cycle = st2utc_ch(shift_cycle);% convert to utc
attemptedRunTime = t.attemptedSpillLogEntryTime();
attemptedRunTime = st2utc_ch(attemptedRunTime);%convert to utc
successfulEventTime = t.utc('all','all',0);
runs_cycle = calc_events_per_time_cycle(attemptedRunTime,shift_cycle);
cd(oldDir);

n_runs_exp = numel(unique(successfulEventTime)); %320
n_cycle = length(runs_cycle);

%rate parameter of number of events per run - Poisson process
lambda_n_Hbars=0.387532;%maximum likelihood estimate

%exponential distribution
start_estimates_poisson = [0.0176038, 13.1318];
%    fit_shifted_poisson(shiftStart_to_firstRun);
%using median MAD(median absolute deviation)
end_estimates_gaussian = [0.339583, 0.0350058];
%   [median(shiftStart_to_lastRun), 1.4826*mad(shiftStart_to_lastRun,1)];

%--------1. decides number of events--------------
%number of runs
rms = sqrt(n_runs_exp);
rand_val1 = random_generator.rand(1);
rand_val2 = random_generator.rand(1);
n_runs_sim = round(get_normal_dis(rand_val1, rand_val2, n_runs_exp, rms));

%number of events per run
n_events = 0;
for i = 1:n_runs_sim
    rand_val = random_generator.rand(1);
    n_events = n_events + get_n_Hbars(rand_val,lambda_n_Hbars);
end
%{
%------2. decides running time------------------
%when first run ends and last run ends
shiftStart_to_firstRun_sim = zeros(n_cycle,1);
shiftStart_to_lastRun_sim = zeros(n_cycle,1);
operationTimes_sim = zeros(n_cycle,1);

for j = 1:n_cycle
 %T1) calculates time when first run ends
    rand_val = random_generator.rand(1);
    shiftStart_to_firstRun_sim(j) = get_occurrence_time(rand_val,start_estimates_poisson(1),start_estimates_poisson(2));
    first_runTime = shift_cycle(j,1) + shiftStart_to_firstRun_sim(j);
    %T2) calculates time when last run ends
    rand_val1 = random_generator.rand(1);
    rand_val2 = random_generator.rand(1);
    shiftStart_to_lastRun_sim(j) = get_normal_dis(rand_val1,rand_val2,end_estimates_gaussian(1),end_estimates_gaussian(2));
    last_runTime = shift_cycle(j,1) + shiftStart_to_lastRun_sim(j);
    %operation time : T2-T1
    operationTimes_sim(j) = last_runTime - first_runTime;
    %if operation time is negative, assume that there is no operation(=0)
    operationTimes_sim(operationTimes_sim <0) = 0;
end

totalOperationTime_sim = sum(operationTimes_sim);

%-------3. decides time for each event----------
eventTimes = zeros(n_events,1);
for l = 1:n_events
    rand_val = random_generator.rand(1);
    %even time relative to the operation time
    eventTime_rel = rand_val*totalOperationTime_sim;
    sum_operationTime = 0;
    operationTime_sim = 0;
    k = 0;  
    while eventTime_rel > ( sum_operationTime + operationTime_sim )
        k = k+1;        
        sum_operationTime = sum_operationTime + operationTime_sim ;
        operationTime_sim = operationTimes_sim(k);
    end
    eventTimes(l) = shift_cycle(k,1) + eventTime_rel - sum_operationTime; 
end

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
plot_time_from_0am(eventTimes);
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