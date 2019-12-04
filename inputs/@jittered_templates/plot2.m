function plot2(this1,this2,stimulus1,stimulus2,COLOR)

figure(gcf); clf reset;

if nargin < 5, COLOR = 1; end

DEFCOLS = {};
if COLOR
  DEFCOLS = { [1.0 0.0 0.0] [0.0 1.0 0.0] [0.0 0.0 1.0] [1.0 0.0 1.0] [0.0 0.0 0.6] [0 0.5 0] [0 1 1] [1 1 0] [1 0 1] [1.0 0.5 0.0] [0 0 0] [0.3 0.0 0.8]};
end

Linewidth = 0.5;

col=0;
maxnt=0;
nSegments=length(this1.segment);
for s=1:length(this1.segment)
  maxnt=max(maxnt,length(this1.segment(s).template));
  col = 0;
  for t=1:length(this1.segment(s).template)
    col=col+1;
    if col < length(DEFCOLS)
      this1.segment(s).template(t).col = DEFCOLS{col};
    else
      this1.segment(s).template(t).col = [ 0 0 0 ];
    end
  end
end

col=0;
maxnt=0;
nSegments=length(this2.segment);
for s=1:length(this2.segment)
  maxnt=max(maxnt,length(this2.segment(s).template));
  col = length(this1.segment(s).template);
  for t=1:length(this2.segment(s).template)
    col=col+1;
    if col < length(DEFCOLS)
      this2.segment(s).template(t).col = DEFCOLS{col};
    else
      this2.segment(s).template(t).col = [ 0 0 0 ];
    end
  end
end

sp1=subplot(3,1,1);
L=this1.Tstim/length(this1.segment);
for s=1:length(this1.segment)
  for t=1:maxnt
    if t <= length(this1.segment(s).template)
      for j=1:length(this1.segment(s).template(t).st)
	st = this1.segment(s).template(t).st{j};
	line([st; st],(t-1)*this1.nChannels+j+[-0.3; 0.3]*ones(1,length(st)),'Color',this1.segment(s).template(t).col,'Linewidth',2);
      end
    else
      text((s-0.5)*L,(t-1)*this1.nChannels+1,sprintf('only %i templates',length(this1.segment(s).template)),...
	  'HorizontalAlignment','center','VerticalAlignment','middle');
    end
  end
end
for t=1:maxnt
  line([0 this1.Tstim],(t-1)*this1.nChannels+[0.5 0.5],'Color','k','Linewidth',Linewidth);
end
for s=1:length(this1.segment)-1
  line([1 1]*L*s,[0.3 maxnt*this1.nChannels+0.5],'Color',[0 0 0]+0.5*(COLOR>1),'Linewidth',Linewidth,'LineStyle','--');
end
line([1 1]*L*length(this1.segment),[0.3 maxnt*this1.nChannels+0.5],'Color',[0 0 0]+0.5*(COLOR>1),'Linewidth',Linewidth,'LineStyle','-');

for s=1:length(this1.segment)
  text(L*(s-0.5),0.2,sprintf('%i. segment',s),'VerticalAlignment','bottom','HorizontalAlignment','center');
end

axis tight
set(gca,'YDir','reverse','YTick',[]);
set(gca,'Xlim',[0 this1.Tstim],'Ylim',[-1 maxnt*this1.nChannels+0.5],'XTick',[]);
th = title(sprintf('possible spike train segments for input to layer 2/3'),'Fontweight','bold');
p = get(th,'position');
set(th,'position',p - [0 8 0])


sp2=subplot(3,1,2);
L=this2.Tstim/length(this2.segment);
for s=1:length(this2.segment)
  for t=1:maxnt
    if t <= length(this2.segment(s).template)
      for j=1:length(this2.segment(s).template(t).st)
	st = this2.segment(s).template(t).st{j};
	line([st; st],(t-1)*this2.nChannels+j+[-0.3; 0.3]*ones(1,length(st)),'Color',this2.segment(s).template(t).col,'Linewidth',2);
      end
    else
      text((s-0.5)*L,(t-1)*this2.nChannels+1,sprintf('only %i templates',length(this2.segment(s).template)),...
	  'HorizontalAlignment','center','VerticalAlignment','middle');
    end
  end
end
for t=1:maxnt
  line([0 this2.Tstim],(t-1)*this2.nChannels+[0.5 0.5],'Color','k','Linewidth',Linewidth);
end
for s=1:length(this2.segment)-1
  line([1 1]*L*s,[0.3 maxnt*this2.nChannels+0.5],'Color',[0 0 0]+0.5*(COLOR>1),'Linewidth',Linewidth,'LineStyle','--');
end
line([1 1]*L*length(this2.segment),[0.3 maxnt*this2.nChannels+0.5],'Color',[0 0 0]+0.5*(COLOR>1),'Linewidth',Linewidth,'LineStyle','-');
for s=1:length(this2.segment)
  text(L*(s-0.5),0.2,sprintf('%i. segment',s),'VerticalAlignment','bottom','HorizontalAlignment','center');
end

axis tight
set(gca,'YDir','reverse','YTick',[]);
set(gca,'Xlim',[0 this2.Tstim],'Ylim',[-1 maxnt*this2.nChannels+0.5],'XTick',[]);
th = title(sprintf('possible spike train segments for input to layer 4'),'Fontweight','bold');
p = get(th,'position');
set(th,'position',p - [0 8 0])


sp3=subplot(3,1,3);

for j=1:this1.nChannels
  ST=stimulus1.channel(this1.nChannels-j+1).data;
  for s=1:nSegments
    t1=(s-1)*L; t2=s*L;
    st = ST(ST>t1 & ST<=t2);
    line([st; st],this2.nChannels + j+[-0.3; 0.3]*ones(1,length(st)),'Color',this1.segment(s).template(stimulus1.info(1).actualTemplate(s)).col,'Linewidth',2);
  end
end

for j=1:this2.nChannels
  ST=stimulus2.channel(this2.nChannels-j+1).data;
  for s=1:nSegments
    t1=(s-1)*L; t2=s*L;
    st = ST(ST>t1 & ST<=t2);
    line([st; st],j+[-0.3; 0.3]*ones(1,length(st)),'Color',this2.segment(s).template(stimulus2.info(1).actualTemplate(s)).col,'Linewidth',2);
  end
end


line([0 this1.Tstim],this1.nChannels+this2.nChannels+[0.5 0.5],'Color','k','Linewidth',Linewidth);
line([0 this1.Tstim],this2.nChannels+[0.5 0.5],'Color','k','Linewidth',Linewidth);

for s=1:length(this1.segment)-1
  line([1 1]*L*s,[0.5 this1.nChannels+this2.nChannels+1.5],'Color',[0 0 0]+0.5*(COLOR>1),'Linewidth',Linewidth,'LineStyle','--');
end
line([1 1]*L*length(this1.segment),[0.3 this1.nChannels+this2.nChannels+0.5],'Color',[0 0 0]+0.5*(COLOR>1),'Linewidth',Linewidth,'LineStyle','-');
for s=1:length(this1.segment)
%  text(L*(s-0.5),this1.nChannels+this2.nChannels+0.7,sprintf('%i. & %i. template',stimulus1.info(1).actualTemplate(s),stimulus2.info(1).actualTemplate(s)),'VerticalAlignment','bottom','HorizontalAlignment','center');
%  text(L*(s-0.5),this1.nChannels+this2.nChannels+0.7,sprintf('templates %i/%i',stimulus1.info(1).actualTemplate(s),stimulus2.info(1).actualTemplate(s)),'VerticalAlignment','bottom','HorizontalAlignment','center');
  text(L*(s-0.5),this1.nChannels+this2.nChannels+0.7,sprintf('templates %i,%i',stimulus1.info(1).actualTemplate(s),stimulus2.info(1).actualTemplate(s)),'VerticalAlignment','bottom','HorizontalAlignment','center');
end
axis tight

set(gca,'Xlim',[0 this1.Tstim],'YLim',[0.5 this1.nChannels+this2.nChannels+1.5]);
xlabel('time [sec]');
if this1.nChannels > 1
   th = title(sprintf('resulting input spike trains'),'Fontweight','bold');
   p = get(th,'position');
   set(th,'position',p + [0 8 0])
else
   title('resulting input spike train','Fontweight','bold');
end
set(gca,'YTick',[]);

% set(sp1,'Position',[0.11 0.46 0.86 0.46]);
% set(sp2,'Position',[0.11 0.15 0.86  0.2]);
% set(sp3,'Position',[0.11 0.15 0.86  0.2]);
