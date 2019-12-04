function plot_instance(this,S)


figure(gcf); clf reset;

for i=1:length(S.info)
  subplot(length(S.info),1,i);
  plot_channels(S.channel(S.info(i).channels));
  title(S.info(i).input_class,'interpreter','none','fontweight','bold');
  axis tight;
  set(gca,'Xlim',[0 S.info(1).Tstim]);
  drawnow;
end
xlabel('times [sec]');