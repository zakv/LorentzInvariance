function [ event_times,n_left ] = generate_event_times(random_generator)
%Returns an array of event times spread randomly between 8/1/2011 and
%12/1/2011 and the number of which are quip left.  A better distribution of
%times should be chosen in the future.
%   The array returned is a column vector of event times in the datenum()
%   format.  Currently, all are assumed to be quip right.

N_EVENTS=386+round(random_generator.rand(1)*10); %Randomly choose some number of
    %events to make sure the code doesn't assume this is fixed
BEGINING=datenum(2011,8,1,0,0,0); %Start of distribution
END=datenum(2011,12,1,0,0,0); %End of distribution

spread=END-BEGINING;
random_numbers=transpose( random_generator.rand(N_EVENTS) );
event_times=spread*random_numbers+BEGINING;
n_left=0;

end