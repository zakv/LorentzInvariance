function [eventTimes,run_first_last,run_start_end] = generate_event_times(random_generator)
%Returns a column vector of event times in UTC.

%METHOD
%**Here, "run" means the one which attempted to trap Hbars.
%Decides time from when shift starts to when first run starts 
%       - shifted exponential (fit the empirical CDF)
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

%-------------get experimental data-------------
oldDir = cd('../../../ExperimentalTimeData/Class');
%gets time information
successful = successful_run();
attempted = attempted_run();
shift = shift_cycle();

successfulEventTime = successful.eventTime('utc','all','all');%utc
shiftCycle = shift.attempted();
attemtpedStartTime = attempted.startTime();
%runTime = attempted.start2end_quench();
cd(oldDir);

%n_Hbars_experiment = vertcat(1*ones(261,1),2*ones(53,1),3*ones(5,1),4*ones(1,1));
%this data is only for figure

%-----------prepare data------------------------
oldDir = cd('../../../ExperimentalTimeData/Code/TimeAnalysisFunction/');
%change the time from local to utc
shiftCycle = st2utc_ch(shiftCycle);
attemtpedStartTime = st2utc_ch(attemtpedStartTime);
%get the first and last run in a shift
[~,runsCycle] = calc_events_per_time_cycle(attemtpedStartTime,shiftCycle);
cd(oldDir);

%shiftStart_to_firstRun = runsCycle(:,1) - shiftCycle(:,1);%for estimation and plot
firstRun_to_lastRun = runsCycle(:,2) - runsCycle(:,1);

totalRunSpan = sum(firstRun_to_lastRun);
n_successfulRuns = numel(unique(successfulEventTime));%number of runs (experiment)
n_cycle = length(runsCycle);%number of shift cycles

%--------calculates estimetes parameter-------------
%probability of getting one Hbar for the run - Poisson process
lambda_n_Hbar=0.387532;%maximum likelihood estimate

%probability of getting successful run in a time
lambda_n_runs=n_successfulRuns/totalRunSpan;

%estimates time from when shift starts to when firstrun starts
start_estimates_poisson = [0.0058050, 9.3289];
        %fit_shifted_exponential(shiftStart_to_firstRun);
        
%estimates time from when the first run starts to when last run starts using mean
end_estimates = [3.4941, 0.066398];
            %gamfit(firstRun_to_lastRun);
%end_estimates_gaussian = [mean(firstRun_to_lastRun), std(firstRun_to_lastRun)];
%time from when run starts to ends; exactly 10 min
runStart2End = 10/60/24;

%----------generate earliest&latest time you can start running----------
eventTimes=zeros(500,1); %Preallocate
row_index=1;
jMax = n_cycle;
run_index = 0;
n_Hbars = zeros(1000,1);

test_n_runs = zeros(jMax,1);
shiftStart_to_firstRun_sim = zeros(jMax,1);
firstRun_to_lastRun_sim = zeros(jMax,1);
first_runTime = zeros(jMax,1);
last_runTime = zeros(jMax,1);

%for plot
run_first_last = zeros(jMax,2);
run_start_end = zeros(1000,2);

for j=1:jMax        
        %T1) get time when first run starts
        rand_val = random_generator.rand(1);
        shiftStart_to_firstRun_sim(j) = get_occurrence_time(rand_val,...
            start_estimates_poisson(1),start_estimates_poisson(2));
        first_runTime(j) = shiftCycle(j,1) + shiftStart_to_firstRun_sim(j);
        %dT) get time span from when first run starts to when last run starts
        rand_val = random_generator.rand(1);
        firstRun_to_lastRun_sim(j) = get_gamma_dis(rand_val,...
            end_estimates(1),end_estimates(2));
        last_runTime(j) = first_runTime(j) + firstRun_to_lastRun_sim(j);
        if last_runTime(j) - shiftCycle(j,1) > 17/24
            disp('warning: shift is longer than 17 hours');
        end
        if j~=jMax
            if shiftCycle(j+1,1) -  last_runTime(j) < 0
                disp('warning: run ends after next shift starts');
            end
        end
end

%---------------------------Get run&event time!----------------------
for j = 1:jMax        
    %for plot
    run_first_last(j,:) = [first_runTime(j), last_runTime(j)];
    %get number of runs per the time span
    rand_val = random_generator.rand(1);
    n_runs = get_n_runs(rand_val,firstRun_to_lastRun_sim(j),lambda_n_runs);
    
    %get time and number of events per each run
    if n_runs >= 1
        runStartTime = zeros(n_runs,1);        
        for i = 1:n_runs
            run_index = run_index + 1;
            %get time cycles where run can start.
            possible_timeCycle = zeros(i+1,2);
            possible_timeCycle(1,1) = first_runTime(j);
            possible_timeCycle(i,2) = last_runTime(j);
            
            for k = 1:i-1
                if runStartTime(k) - runStart2End < possible_timeCycle(k,1)
                    possible_timeCycle(k,2) = possible_timeCycle(k,1);
                else
                possible_timeCycle(k,2) = runStartTime(k) - runStart2End;                    
                end
                possible_timeCycle(k+1,1) = runStartTime(k) + runStart2End;
            end
            if possible_timeCycle(i,1) > last_runTime(j)
                possible_timeCycle(i,2) = possible_timeCycle(i,1);             
            end
            
            if sum(possible_timeCycle(:,2)-possible_timeCycle(:,1))<0
                disp('error: A run cannot be assigned to the too short shift.');
            end
            %get the time when run starts, but exclude the run spans
            %that were already assigned and the time length of runSpan
            %before when the next run starts.
            rand_val = random_generator.rand(1);
            runStartTime_scaled = sum(possible_timeCycle(:,2)-possible_timeCycle(:,1))*rand_val;  
            possible_time = 0;
            n_cycle = 0;
            while runStartTime_scaled > possible_time
               last_possible_time = possible_time;
               n_cycle = n_cycle + 1;
               possible_time = possible_time +...
                   (possible_timeCycle(n_cycle,2) - possible_timeCycle(n_cycle,1));
            end
            
            %Finally get time when run starts
            runStartTime(i) = runStartTime_scaled - last_possible_time +...
                possible_timeCycle(n_cycle,1);
            %Gets eventTime
            eventTime = runStartTime(i) + runStart2End;
            
            %for plot
            run_start_end(run_index,:) = [runStartTime(i), eventTime];
            
            %sort the time from past to present
            runStartTime = sort(runStartTime);
            %put zeros at the end of the array
            runStartTime = circshift(runStartTime,i - n_runs);
            
            %get number of events(>=1) per run
            rand_val = random_generator.rand(1);
            n_Hbars(run_index) = get_n_Hbars(rand_val,lambda_n_Hbar);
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
%n_Hbars=n_Hbars(used_indices);%for plot

%for plot
used_indices=run_start_end(:,1)~=0;
run_start_end=run_start_end(used_indices,:);

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
plot_time_date(eventTimes,'r');
set_for_time_graph();
cd(oldDir);

saveas(f_events_diagram,'eventTimes_diagram.pdf','pdf');
%}
%---------for CHECK ---write total number of event % run,and run span------
dispstr = ['total number of run is ',num2str(sum(test_n_runs)),...
' (experiment:',num2str(n_successfulRuns),')'];
disp(dispstr);
dispstr = ['total run span is ',num2str(sum(firstRun_to_lastRun_sim)),...
' (experiment:',num2str(totalRunSpan),')'];
disp(dispstr);
dispstr = ['total number of event time is ',num2str(numel(eventTimes)),...
' (experiment:',num2str(numel(successfulEventTime)),')'];
disp(dispstr);

end

function [time] = get_occurrence_time(rand_val,t_0,time_lambda)
%Use poisson process and rand_val to pick a time. rand_val is the exclusive
% event of the possibility not happening any event at specific time.
time = - log(1 - rand_val)/time_lambda + t_0;
end

%{
function[value] = get_normal_dis(rand_val,mu,std)
value = sqrt(2*std^2)*erfinv(2*rand_val - 1) + mu;
end
%}

function [time] = get_gamma_dis(rand_val,k,theta)
    time = theta*gammaincinv(rand_val,k);
end

function [n_Hbars] = get_n_Hbars(rand_val,lambda_n_Hbar)
%Gives the number of Hbars in a given trapping run.

%n_Hbars>=1
probability=@(n)lambda_n_Hbar^n*exp(-lambda_n_Hbar)/factorial(n);
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
function [estimates] = fit_shifted_exponential(data)
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