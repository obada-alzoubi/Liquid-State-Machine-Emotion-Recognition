function plot(this,stimulus,COLOR,FS)

figure(gcf); clf;

if nargin < 3, COLOR = 1; end
if nargin < 4, FS = 1; end

DEFCOLS = {};
if COLOR
  DEFCOLS = { [1.0 0.0 0.0] [0.0 0.0 1.0] [1.0 0.0 0.0] [0.0 0.0 1.0] [1 0.0 0] [0 0.0 1.0] [1.0 0.0 0] [1 0 0] [0 0 1] [1 0 0] [0 0 1] [1 0 0] [0 0 1]};
end

col=0;
maxnt=0;
nSegments=length(this.segment);
for s=1:length(this.segment)
  maxnt=max(maxnt,length(this.segment(s).template));
  for t=1:length(this.segment(s).template)
    col=col+1;
    if col < length(DEFCOLS)
      this.segment(s).template(t).col = DEFCOLS{col};
    else
      this.segment(s).template(t).col = [ 0 0 0 ];
    end
  end
end

sp1=subplot(2,1,1);
L=this.Tstim/length(this.segment);
for s=1:length(this.segment)
  for t=1:maxnt
    if t <= length(this.segment(s).template)
      for j=1:length(this.segment(s).template(t).st)
	st = this.segment(s).template(t).st{j};
	line([st; st],(t-1)*this.nChannels+j+[-0.3; 0.3]*ones(1,length(st)),'Color',this.segment(s).template(t).col,'Linewidth',2);
      end
    else
      text((s-0.5)*L,(t-1)*this.nChannels+1,sprintf('only %i templates',length(this.segment(s).template)),...
	  'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',10*FS);
    end
  end
end
for t=1:maxnt
  line([0 this.Tstim],(t-1)*this.nChannels+[0.5 0.5],'Color','k','Linewidth',1);
end
for s=1:length(this.segment)-1
  line([1 1]*L*s,[0.3 maxnt*this.nChannels+0.5],'Color',[0 0 0]+0.5*(COLOR>1),'Linewidth',1,'LineStyle','--');
end
for s=1:length(this.segment)
  text(L*(s-0.5),0.2,sprintf('%i. segment',s),'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',10*FS);
end

axis tight
set(gca,'YDir','reverse','YTick',[]);
set(gca,'Xlim',[0 this.Tstim],'Ylim',[-1 maxnt*this.nChannels+0.5],'XTick',[]);
title('possible spike train segments','Fontweight','bold','FontSize',10*FS);

sp2=subplot(2,1,2);
for j=1:this.nChannels
  ST=stimulus.channel(j).data;
  for s=1:nSegments
    t1=(s-1)*L; t2=s*L;
    st = ST(ST>t1 & ST<=t2);
    line([st; st],j+[-0.3; 0.3]*ones(1,length(st)),'Color',this.segment(s).template(stimulus.info(1).actualTemplate(s)).col,'Linewidth',2);
  end
end
for s=1:length(this.segment)-1
  line([1 1]*L*s,[0.5 this.nChannels+0.5],'Color',[0 0 0]+0.5*(COLOR>1),'Linewidth',1,'LineStyle','--');
end
for s=1:length(this.segment)
  text(L*(s-0.5),-1.3,sprintf('template %i',stimulus.info(1).actualTemplate(s)-1),'FontSize',10*FS,'VerticalAlignment','top','HorizontalAlignment','center');
end
axis tight
set(gca,'Xlim',[0 this.Tstim],'YLim',[-1 this.nChannels+0.5],'YDir','reverse','FontSize',10*FS);
xlabel('time [sec]','FontSize',10*FS);
if this.nChannels > 1
   title('resulting input spike trains','Fontweight','bold','FontSize',10*FS);
else
   title('resulting input spike train','Fontweight','bold','FontSize',10*FS);
end
set(gca,'YTick',[]);

set(sp1,'Position',[0.1 0.51 0.86 0.4]);
set(sp2,'Position',[0.1 0.17 0.86  0.22]);
