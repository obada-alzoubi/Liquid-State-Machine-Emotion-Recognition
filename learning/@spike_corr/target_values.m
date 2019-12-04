function Y=target_function(this,stimulus,at_t)

spikes = [stimulus.channel(this.channels).data];

spikes = sort(spikes);

% n0=length(spikes);
% spikes  = unique(spikes);
% n1=length(spikes);
% if ( n1 ~= n0 )
%   fprintf('%i spikes lost!\n',n0-n1);
% end
% t1 = [0 spikes+this.delay];         % at times t1 a spike enters the interval [t-delay-W,t-delay]
% t2 = [0 spikes+this.delay+this.W];  % at times t2 a spike leaves the interval [t-delay-W,t-delay]
% r  = 0:length(spikes);              % a ramp which has the following meaning: 
%                                     % (t1,r) describes the function which counts all spikes in [0,t-delay]
%                                     % (t2,r) describes the function which counts all spikes in [0,t-delay-W]
% 
% 
% % calculate the number of spikes within the interval [t-delay-W,t-delay] as
% % the difference between (t1,r) and (t2,r)
% %
% % S is the number of spikes within the interval [t-delay-W,t-delay]
% S = interp1(t1,r,at_t,'linear','extrap')-interp1(t2,r,at_t,'linear','extrap');
% 
% % b ... number of bins
% b = this.W/this.delta;
% 
% n ... number of relevent channels
n = length(this.channels);
% 
% % r ... average rate per channel
% r = S/(this.W*n);
% 
% % p = Prob{ spike in bin [t,t+delta] }
% p = this.delta*r;
% 
% % p^n ... Prob{ simultaneous spikes in n channels in bin [t,t+delta] }
% % cbar ... expected number of spike conincedences within b bins
% cbar = b * p.^n;

%
% count the actual spike conincedences c
%
% c = zeros(size(at_t));
% for i_t = 1:length(at_t)
%   t=[(at_t(i_t)-this.W):(this.delta):at_t(i_t)]-this.delay;
% 
%   % h(j) counts in how many channels one ore more spikes occured
%   h=zeros(1,length(t));
%   for i=1:n
%     h = h + (histc(stimulus.channel(this.channels(i)).data,t)>0);
%   end
%   % now we count how often it occured that there were one 
%   % (ore more) spike(s) in each of the n channels.
%   % This gives us the number of spike coincidences
%   c(i_t) = sum(h==n);
% end

s=ones(1,n);
ii=0;
tco=NaN*ones(size(spikes));
for t=spikes
  c=zeros(1,n);
  for i=1:n
    st=stimulus.channel(this.channels(i)).data;
    st(st<t-this.delta)=[];
    if ~isempty(st)
      if st(1) <= t
	c(i) = c(i)+1;
      end
    end
    stimulus.channel(this.channels(i)).data=st;
  end 
  if all(c>0)
    ii=ii+1; tco(ii) = t;
  end
%  cla; 
%  plot_channels(stimulus.channel(this.channels)); hold on;
%  line([spikes; spikes],[1; 2]*ones(size(spikes)),'Color','b');
%  line(ones(2,1)*[t t-this.delta],[1; 2]*ones(1,2),'Color','r');
%  set(gca,'Xlim',[0 at_t(end)],'YLim',[0 3]);
%  c
%  pause
end
tco(isnan(tco))=[];

Y=zeros(size(at_t));
for i=1:length(at_t)
  Y(i)=sum(at_t(i)-this.W-this.delay < tco & tco <= at_t(i)-this.delay);
end

%plot(tco,ones(size(tco)),'r*');
%line([spikes; spikes],[1; 2]*ones(size(spikes)),'Color','b');
%line([tco; tco],[1; 2]*ones(size(tco)),'Color','r');
%keyboard

