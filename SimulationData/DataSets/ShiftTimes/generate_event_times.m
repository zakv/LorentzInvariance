function [ event_times,n_left ] = generate_event_times()
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
    rand_val=rand();
    event_time=shift_start+get_interarrival_time(rand_val,time_lambda);
    while event_time<shift_end
        rand_val=rand();
        n_Hbars=get_n_Hbars(rand_val,n_Hbar_lambda);
        %Add this to output event_times
        event_times(row_index:row_index+n_Hbars-1)=event_time;
        %Prepare for next iteration
        row_index=row_index+n_Hbars;
        rand_val=rand();
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

%Below is some old code from when I had the wrong function for the
%interarrival_time cdf.  It should no longer be necessary and will be
%deleted in a future commit

% function [interarrival_time] = get_interarrival_time(rand_val,time_lambda)
% %Uses bisection to find inverse of the cdf
% %   Returns the time corresponding to where the cdf equals the given random
% %   value
% 
% tol=0.1/(24.0*60.0*60.0); %tolerance of 0.1 seconds
% cdf_func=@(t)t+(exp(-time_lambda*t)-1)/time_lambda;
% left=0;
% right=1/24.0; %first guess for right end point is 1 hour
% 
% %Increase right value if necessary
% while cdf_func(right)<rand_val
%     left=right; %move left over
%     right=right*2; %move right over
% end
% 
% %Perfrom bisection
% interarrival_time=bisect(cdf_func,rand_val,left,right,tol);
% 
% end
% 
% 
% function middle = bisect(function_handle,rand_val,left,right,tol)
% %Returns the x-value of where the function's output is rand_val
% %   Used to get the inverse of the cdf at a particular y-value.  Only works
% %   on monotonically increasing functions.
% 
% %Make sure input is suitable for bisection
% if function_handle(left)>rand_val
%     msgIdent='generate_event_times:bisect:InvalidLeftValue';
%     msgString='The given left value must give a function value ';
%     msgString=[msgString,'less than rand_val.'];
%     error(msgIdent,msgString);
% elseif function_handle(right)<rand_val
%     msgIdent='generate_event_times:bisect:InvalidRightValue';
%     msgString='The given right value must give a function value ';
%     msgString=[msgString,'greater than rand_val.'];
%     error(msgIdent,msgString);
% end
% 
% middle=(left+right)*0.5;
% n_iterations=0;
% max_iterations=1000;
% while right-left>tol && n_iterations<max_iterations
%     current_val=function_handle(middle);
%     if current_val>rand_val
%         left=middle;
%     elseif current_val<rand_val
%         right=middle;
%     elseif current_val==rand_val
%         return
%     end
%     middle=0.5*(right+left);
%     n_iterations=n_iterations+1;
% end
% end
