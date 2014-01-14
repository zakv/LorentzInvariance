function [ event_times ] = generate_event_times()
%Returns an array of 312 event times spread randomly between 8/1/2011 and
%12/1/2011.  A better distribution of times should be chosen in the
%future
%   The array returned is a column vector of event times in the datenum()
%   format.
N_EVENTS=Analysis.N_EVENTS;
BEGINING=datenum(2011,8,1,0,0,0); %Start of distribution
END=datenum(2011,12,1,0,0,0); %End of distribution

spread=END-BEGINING;
event_times=spread*rand(N_EVENTS,1)+BEGINING;

end