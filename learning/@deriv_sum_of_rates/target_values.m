function Y=target_function(this,input,at_t)

d=length(input.channel);
%
% merge all spikes to s single spike train S
%
S = [];
for j=1:d
  S = [S input.channel(j).data];
end

S  = sort(S);
t1 = [0 S+this.delay];       % at times t1 a spike enters the interval [t-delay-W,t-delay]
t2 = [0 S+this.delay+this.W];  % at times t2 a spike leaves the interval [t-delay-W,t-delay]
r  = 0:length(S);          % a ramp which has the following meaning: 
                           % (t1,r) describes the function which counts all spikes in [0,t-delay]
                           % (t2,r) describes the function which counts all spikes in [0,t-delay-W]

Tmax = max(at_t);
%
% now calc the number of spikes within the interval [t-delay-W,t-delay] as
% the difference between (t1,r) and (t2,r)
%
dt=1e-3;
t = 0:dt:Tmax;
y = interp1(t1,r,t)-interp1(t2,r,t); % y is the number of spikes within the interval [t-delay-W,t-delay]

%
% we normailze y to the range [0,1] as follows:
% Note that there are at most d*W*fmax spikes within an interval of length W,
% since each spike train has at most one spike 
% within an interval of length 1/fmax
%

y = y / (d*this.W*this.fmax);
y = max(min(y,1),0);         % this may be neccesarry due to the arbitrary choise of 'dt'

%
% calc some 'derivative'
%
m=100;
ysmooth=filter(1/m*ones(1,m),1,y);
ysmooth=[ysmooth(50:end) NaN*ones(1,49)];
%plot(t,y,t,ysmooth);
%pause
dy=[0 diff(ysmooth)]*40+0.5;
dy=[0 diff(ysmooth)]>=0;
t = t;
y = dy;
y(t<this.delay+2*this.W) = NaN;

Y = interp1(t,y,at_t);






