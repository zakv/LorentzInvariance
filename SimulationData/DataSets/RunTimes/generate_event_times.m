function [ event_times,n_left ] = generate_event_times(random_generator)
%Need to update the lambda values.

%Returns a column vector of event times in Geneva time chosen to be Poisson
%distributed over the estimated times during which the experiment was
%running.  The number of events per detection is also assumed to be
%Poissonian (with the restriction that it is greater than or equal to one).
%Currently all data points are assumed to be quip right.

%Constants (should update these values)
n_Hbar_lambda=0.338;
time_lambda=14.199513; %Days/event

run_times_obj=load('AttemptedStartingTimeCycleData.mat');

run_starts_ends=run_times_obj.timeCycle;
event_times=zeros(500,1); %Preallocate
row_index=1;
jMax=size(run_starts_ends,1);
for j=1:jMax
    shift_start=run_starts_ends(j,1);
    shift_end=run_starts_ends(j,2);
    rand_val=random_generator.rand(1);
    event_time=shift_start+get_interarrival_time(rand_val,time_lambda);
    while event_time<shift_end
        rand_val=random_generator.rand(1);
        n_Hbars=get_n_Hbars(rand_val,n_Hbar_lambda);
        %Add this to output event_times
        event_times(row_index:row_index+n_Hbars-1)=event_time;
        %Prepare for next iteration
        row_index=row_index+n_Hbars;
        rand_val=random_generator.rand(1);
        event_time=event_time+get_interarrival_time(rand_val,time_lambda);
    end
end

%Strip unused rows of preallocated array
used_indices=event_times~=0;
event_times=event_times(used_indices);
n_left=0;

end

function [interarrival_time] = get_interarrival_time(rand_val,time_lambda)
%Uses the Poisson interarrival time cdf and rand_val to pick an arrival
interarrival_time=-log(1-rand_val)/time_lambda;
end

function [n_Hbars] = get_n_Hbars(rand_val,n_Hbar_lambda)
%Gives the number of Hbars in a given trapping run.

% probability=@(n)n_Hbar_lambda^n*exp(-n_Hbar_lambda)/factorial(n);
% n_Hbars=0;
% running_probability=probability(n_Hbars);
% while running_probability<rand_val
%     n_Hbars=n_Hbars+1;
%     running_probability=running_probability+probability(n_Hbars);
% end

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
