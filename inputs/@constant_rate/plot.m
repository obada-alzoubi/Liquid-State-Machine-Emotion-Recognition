function plot(this,S)

figure(gcf); clf reset;


subplot(2,1,1);
binwidth=20e-3;
tr=0:S.info(1).dt:S.info(1).Tstim;
[y,ty]=spikes2rate([S.channel(:).data],binwidth);
plot(tr,S.info(1).r,ty,y/this.nChannels,'r--');
axis tight
set(gca,'XLim',[0 S.info(1).Tstim]);
xlabel('time [s]');
ylabel('rate per spike train');
ty(isnan(y))=[];
y(isnan(y))=[];
y=interp1(ty,y,tr,'linear','extrap');
title(sprintf('rates (xcorr=%g)',corr_coef(S.info(1).r,y)));
legend('r(t)',sprintf('r_{measured} [binwidth=%gms]',binwidth*1000),0);


subplot(2,1,2); cla reset; hold on;
for j=1:this.nChannels
  st=S.channel(j).data;
  plot([st; st],j*ones(1,length(st)),'k.');
end
set(gca,'XLim',[0 S.info(1).Tstim],'Ylim',[0.5 this.nChannels+0.5],'Ydir','reverse');
xlabel('time [s]');
ylabel('spike train #');
title('spike trains','FontWeight','bold');
