function plot_channels(channel, Tstim)

if nargin < 2, Tstim = []; end

ac = find([channel(:).spiking]==0);
if ~isempty(ac)
  S=zeros(size(ac));
  for a=1:length(ac)
    R(a)=max(channel(ac(a)).data);
    R(a)=R(a)-min(channel(ac(a)).data);
  end
  A = 1.5*max(R);
else
  A = 1;
end

cla reset; hold on;
for c=1:length(channel)
  if channel(c).spiking
    st=channel(c).data;
    plot(st,c*ones(1,length(st)),'k.');
  else
    if ~isempty(Tstim)
      t=[[0:length(channel(c).data)-1]*channel(c).dt Tstim];
    else
      t=[0:length(channel(c).data)]*channel(c).dt;
    end      
    stairs(t,c+[channel(c).data channel(c).data(end)]/A);
  end
end
axis tight;
if ~isempty(Tstim)
  set(gca,'Xlim',[0 Tstim]);
end
