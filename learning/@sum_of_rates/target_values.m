function y=target_values(this,S,at_t)

d=length(S.channel);
%
% merge all spikes to a single spike train spikes
%
if isempty(this.channels)
  spikes = [S.channel(:).data];
else
  spikes = [S.channel(this.channels).data];
end

n0=length(spikes);
spikes  = unique(spikes);
n1=length(spikes);
if ( n1 ~= n0 )
  fprintf('%i spikes lost!\n',n0-n1);
end
t1 = [0 spikes+this.delay];       % at times t1 a spike enters the interval [t-delay-W,t-delay]
t2 = [0 spikes+this.delay+this.W];  % at times t2 a spike leaves the interval [t-delay-W,t-delay]
r  = 0:length(spikes);          % a ramp which has the following meaning: 
                           % (t1,r) describes the function which counts all spikes in [0,t-delay]
                           % (t2,r) describes the function which counts all spikes in [0,t-delay-W]


Tmax = spikes(end)+this.delay+this.W;		  

% now calc the number of spikes within the interval [t-delay-W,t-delay] as
% the difference between (t1,r) and (t2,r)
%
dt=1e-3;
t = 0:dt:Tmax;
% y is the number of spikes within the interval [t-delay-W,t-delay]
y = interp1(t1,r,t,'linear','extrap')-interp1(t2,r,t,'linear','extrap');

%
% we normailze y to the range [0,1] as follows:
% Note that there are d*W*f_max spikes within an interval of length W,
% since each spike train has at most one spike 
% within an interval of length 1/f_max
%

y = y / (d*this.W*this.fmax);
y = max(min(y,1),0);         % this may be neccesarry due to the arbitrary choise of 'dt'


y(t<this.delay+this.W) = NaN;

y = interp1(t,y,at_t);






