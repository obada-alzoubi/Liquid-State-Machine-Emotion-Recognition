function plot_response(Rin)

figure(gcf); clf reset;
nR = length(Rin);
Tmax = 0;

for r=1:nR
  subplot(nR,1,r);
  plot_channels(Rin{r}.channel,Rin{r}.Tsim);
  axis tight
  xl=get(gca,'Xlim');
  Tmax = max(Tmax,xl(2));
end
for r=1:nR
  set(gca,'Xlim',[0 Tmax]);
end

subplot(nR,1,1);
title('circuit response','fontweight','bold');

subplot(nR,1,nR);
xlabel('time [sec]');

drawnow;
