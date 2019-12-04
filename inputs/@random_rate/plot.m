function plot_instance(this,S,Tseg)


if nargin < 3, Tseg = 0; end

figure(gcf); clf;

subplot(3,1,1);
binwidth=30e-3;this.binwidth;
tr=0:S.info(1).dt:S.info(1).Tstim;
[y,ty]=spikes2rate([S.channel(:).data],binwidth);
plot(tr,S.info(1).r,ty,y/this.nChannels,'r--');
axis tight
set(gca,'XLim',[0 S.info(1).Tstim]);
xlabel('time [s]');
ylabel('rate per spike train [Hz]');
ty(isnan(y))=[];
y(isnan(y))=[];
y=interp1(ty,y,tr,'linear','extrap');
title('rates','FontWeight','bold');
%sprintf('rates (xcorr=%g)',corr_coef(S.info(1).r,y))
legend('r(t)',sprintf('r_{measured} (\\Delta=%gms)',binwidth*1000));


subplot(3,1,2); cla reset; hold on;
for j=1:this.nChannels
  st=S.channel(j).data;
  line([st; st],[-0.3; 0.3]*ones(size(st))+j,'Color','k');
end
set(gca,'XLim',[0 S.info(1).Tstim],'Ylim',[0.5 this.nChannels+0.5],'YTick',1:this.nChannels);
xlabel('time [s]');
ylabel('spike train #');
title('spike trains','FontWeight','bold');


subplot(3,1,3);
if Tseg > 0
  r=rand_rate(this,Tseg);
  cr=crosscorr(r-mean(r),500,'coeff');  
else
  Tseg=S.info(1).Tstim;
  cr=crosscorr(S.info(1).r-mean(S.info(1).r),500,'coeff');
end
tr=([0:length(cr)-1]-length(cr)/2)*1e-3;

y(isnan(y))=[];
cs=crosscorr(y-mean(y),500,'coeff');
%cs=cs(ceil(length(cs)/2)-200:end);
ts=([0:length(cs)-1]-length(cs)/2)*1e-3;

plot(tr,cr,ts,cs,'r--');
xlabel('lag [s]');
ylabel('correlation coeff');
mm=max(abs(min([tr ts])),abs(max([tr ts])));
set(gca,'Ylim',[min(cs) 1],'Xlim',[-mm mm]);
title('auto-correlation','FontWeight','bold');
legend(sprintf('r(t)',Tseg),sprintf('r_{measured} (\\Delta=%gms)',binwidth*1000));


drawnow;
