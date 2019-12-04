function plot(this,varargin)
%PLOT Plots analog input templates and stimuli.
%   PLOT(IT) plots matlab figures of the analog input templates IT.channel
%   starting with the current figure number GCF.
%
%   PLOT(IT,'pdf',FILENAME) plots matlab figures and creates a pdf file
%   FILENAME of the analog input templates IT.channel.
%
%   PLOT(IT,'show pdf',FILENAME) additional opens the created pdf file with
%   the acrobat reader.
%
%   PLOT(IT,S,...) plots the analog input stimulus S created from the analog
%   input templates IT and the transformation parameters for its generation.
%   This function call is identical to the function call PLOT_INSTANCE(IT,S,...),
%   so please see 
%
%      help plot_instance
%
%   for further details.
%
%   See also ANALOG_INPUT_SET/PLOT_INSTANCE, ANALOG_INPUT_SET/GENERATE
%	     ANALOG_INPUT_SET/ANALOG_INPUT_SET
%
%   Author: Stefan Haeusler, 10/2002, haeusler@igi.tu-graz.ac.at


% check input arguments

if (nargin > 1)
   if ~isstr(varargin{1})
      plot_instance(this,varargin{:})
      return
   end
end


filename = [];
SHOW_PDF = 0;

i = 1;
while i <= (nargin-1)
   if isempty(strmatch('char',class(varargin{i}),'exact'))
       errstr = sprintf('Function ''plot'' not defined for variables of class ''%s''.',class(varargin{i}))
       error(errstr);
   else
      % check if argument is present
      if (i+1)>(nargin-1)
         errstr = sprintf('Not enough input arguments for command ''%s''.',varargin{i});
         error(errstr);
      end

      % check if second argument is of the correct class
      if isempty(strmatch('char',class(varargin{i+1}),'exact'))
         errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
         error(errstr);
      end

      switch varargin{i}
         case 'pdf'
            filename = varargin{i+1};
         case 'show pdf'
            filename = varargin{i+1};
            SHOW_PDF = 1;
         otherwise
            errstr = sprintf('Invalid command ''%s''.',varargin{i});
            error(errstr)
      end
   end
end

nFig = gcf;

if filename & ~isempty(which('temp.ps'))
   delete temp.ps
end

nsb = 6;

IT  = this.channel;

for nIT = 1:length(IT)

   figure(nFig+floor((nIT-1)/nsb))
   set(gcf,'Color',[1 1 1]) 
   subplot(nsb,1,mod(nIT-1,nsb)+1)
   cla
   set(gca,'Color',[1 1 1]) 

   plot([1:length(IT(nIT).data)]*IT(nIT).dt,IT(nIT).data,'k-')
   axis([0  length(IT(nIT).data)*IT(nIT).dt ...
         min(-0.25,min(IT(nIT).data)) max(1.25,max(IT(nIT).data))])

   set(gca,'YTick',[0 1]) 
   ylabel('I [A]')
   if (mod(nIT-1,nsb) == 0)
      text(0.5,1.6,sprintf('%s',this.name),'FontSize',10,'VerticalAlignment','bottom','HorizontalAlignment','center')
   end
   title(sprintf('\n%s',IT(nIT).name),'FontSize',15,'VerticalAlignment','top')

   box off
   Color = get(gcf,'Color');
   set(gca,'Color',Color)

   if (mod(nIT-1,nsb) == nsb-1)
      drawnow
      set(gcf,'PaperPosition',[0.25 0.25 8 10.5]);
      xlabel('time [sec]')

      if filename
         print -dpsc2 -append temp.ps
      end
   end
end

if filename
   eval(sprintf('!ps2pdf temp.ps %s',filename))
   if SHOW_PDF
      fprintf('Close Acrobat Reader to proceed!\n')
      eval(sprintf('!acroread %s',filename))
   end
   delete temp.ps
end


