function spike_trains=rate2spikes(u,dt,d,Tmax);

if nargin < 3, Tmax = Inf; end
  
t=[0:length(u)-1]*dt;

for i=1:d
  %
  % with prob u*dt*MaxFreq there is a spike in time bin [t,t+dt]
  %
  st=t(rand(size(u))<u*dt);
  
  %
  % jitter spikes within interval [t,t+dt]
  %
  if ~isempty(st)
    st = st + dt*rand(size(st));
  end

  % restrict to Tmax
  st(st>Tmax)=[];

  %
  % save result
  %
  spike_trains{i} = st;
end
