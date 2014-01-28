function [ event_times,n_left ] = generate_event_times(random_generator)
%Need to chance which random number generator is used.  Need to update the
%lambda values.

%Returns a column vector of event times in Geneva timechosen to be Poisson distributed
%over the estimated shift schedule.  The number of events per detection is
%also assumed to be Poissonian (with the restriction that it is greater
%than or equal to one).  Currently all data points are assumed to be quip
%right.

%Constants (should update these values)
n_Hbar_lambda=0.338;
time_lambda=1/(1.306/24.0); %For now set it to one per 1.306 hour
    %(see histWaitingRunTime_12h_allV2.pdf)

shift_starts_ends=xlsread('GuessedShiftScheduleV2.xlsx','Sheet1','A2:B90','basic');
shift_starts_ends=x2mdate(shift_starts_ends); %Convert to matlab dates
event_times=zeros(500,1); %Preallocate
row_index=1;
jMax=size(shift_starts_ends,1);
for j=1:jMax
    shift_start=shift_starts_ends(j,1);
    shift_end=shift_starts_ends(j,2);
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
