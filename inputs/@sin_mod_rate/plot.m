function plot_instance(this,S)


figure(gcf); clf reset;

subplot(3,1,1);
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
title(sprintf('rates (xcorr=%g)',corr_coef(S.info(1).r,y)),'FontWeight','bold');
legend('r(t)',sprintf('r_{measured} [binwidth=%gms]',binwidth*1000),0);


subplot(3,1,2); cla reset; hold on;
for j=1:this.nChannels
  st=S.channel(j).data;
  plot([st; st],j*ones(1,length(st)),'k.');
end
set(gca,'XLim',[0 S.info(1).Tstim],'Ylim',[0.5 this.nChannels+0.5],'Ydir','reverse');
xlabel('time [s]');
ylabel('spike train #');
title('spike trains','FontWeight','bold');


subplot(3,1,3);
cr=crosscorr(S.info(1).r-mean(S.info(1).r),500,'coeff');
%cr=cr(floor(length(cr)/2)-100:end);
tr=([0:length(cr)-1]-length(cr)/2)*1e-3;

y(isnan(y))=[];
cs=crosscorr(y-mean(y),500,'coeff');
%cs=cs(ceil(length(cs)/2)-200:end);
ts=([0:length(cs)-1]-length(cs)/2)*1e-3;


plot(tr,cr,ts,cs,'r-');
xlabel('lag [s]');
ylabel('correlation coeff');
axis tight
title('autocorr','FontWeight','bold');
legend('r(t)',sprintf('r_{measured} [binwidth=%gms]',binwidth*1000),0);


drawnow;
