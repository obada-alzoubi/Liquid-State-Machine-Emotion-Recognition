function [r,t]=spikes2rate(S,binwidth);

S  = unique(S);
t1 = [0 S];    % at times t1 a spike enters the interval [t-binwidth,t]
t2 = [0 S+binwidth];  % at times t2 a spike leaves the interval [t-binwidth,t]
r  = 0:length(S);          % a ramp which has the following meaning: 
                           % (t1,r) describes the function which counts all spikes in [0,t]
                           % (t2,r) describes the function which counts all spikes in [0,t-binwidth]

Tmax = S(end)+binwidth;		  

% now calc the number of spikes within the interval [t-delay-W,t-delay] as
% the difference between (t1,r) and (t2,r)
%
dt=1e-3;
t = 0:dt:Tmax;
r = interp1(t1,r,t,'linear')-interp1(t2,r,t,'linear'); % y is the number of spikes within the interval [t-delay-W,t-delay]
r = r/binwidth;
