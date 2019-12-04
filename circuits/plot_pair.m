function plot_pair(S,Rin)

figure(gcf); clf reset;
nR = length(Rin);
Tmax = 0;

subplot(nR+1,1,1);
plot_stimulus(S,Rin{1}.Tsim);

for r=1:nR
  subplot(nR+1,1,r+1);
  plot_channels(Rin{r}.channel,Rin{r}.Tsim);
%  axis tight
  xl=get(gca,'Xlim');
  Tmax = max(Tmax,xl(2));
end
for r=1:nR
  set(gca,'Xlim',[0 Tmax]);
end

subplot(nR+1,1,2);
title('circuit response','fontweight','bold');

subplot(nR+1,1,nR+1);
xlabel('time [sec]');

drawnow;
