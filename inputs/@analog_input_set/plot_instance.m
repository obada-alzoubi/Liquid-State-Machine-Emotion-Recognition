function plot_instance(this,varargin)
%PLOT_INSTANCE Plots analog input stimuli.
%   PLOT_INSTANCE(IT,S) plots the analog input stimulus S created from the analog 
%   input templates IT and the transformation parameters for its generation in the 
%   current figure GCF.
%
%   PLOT_INSTANCE(IT,S1,S2,...) plots the analog input stimuli S1, S2, etc. in the 
%   current figure GCF and the transformation parameters used for the generation 
%   of the stimuli in subsequent figures.
%
%   PLOT_INSTANCE(IT,S1,...,'pdf',FILENAME) plots matlab figures and creates a 
%   pdf file FILENAME of the analog input stimuli and transformation parameters.
%
%   PLOT_INSTANCE(IT,S1,...,'show pdf',FILENAME) additional opens the created 
%   pdf file with the acrobat reader.
%
%   PLOT_INSTANCE(IT,S1,...,'offset',OFFSET) sets the offset of the graphic 
%   coordinates in the subplot of the analog input stimuli, where OFFSET is a 
%   three dimensional vector of class 'double'.
%
%   PLOT_INSTANCE(IT,S1,...,'subplot',SUBPLOT) specifies the subplots in which
%   the two parts: stimuli and transformation parameters are plotted. Each
%   subplot is plotted in another figure starting with the current figure GCF.
%
%   Example:   plot_instance(IT,S{[1 3]},'subplot',[0 911])   
%
%              plots the transformation parameters of stimuli 1 and 3 in subplot(911)
% 	       and no analog input signal.
%
%
%   See also ANALOG_INPUT_SET/GENERATE, ANALOG_INPUT_SET/PLOT
%	     ANALOG_INPUT_SET/ANALOG_INPUT_SET
%
%   Author: Stefan Haeusler, 10/2002, haeusler@igi.tu-graz.ac.at

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:(nargin-1)
   class_names{i} = class(varargin{i});
end

% identify input stimuli
%-----------------------------

idx = strmatch('struct',class_names,'exact');
if isempty(idx)
   error('Stimulus must be of class ''struct''.')
end

for i = 1:length(idx)
   ST{i} = varargin{idx(i)};
end



% identify command strings
%-------------------------

% default values

if length(ST) == 1
   sub_plot = [211 212];
else
   sub_plot = [111 411];
end  
LIST_PLOT = 1;
offset = [0 0 0];
filename = [];
SHOW_PDF = 0;

% execute commands

str = [];
idx = strmatch('char',class_names,'exact')';
j = 1;
while j <= length(idx)
      i = idx(j);

      % check if second argument is present
      if (i+1)>(nargin-1)
        errstr = sprintf('Not enough input arguments for command ''%s''.',varargin{i});
        error(errstr);
      end

      switch varargin{i}
         case 'pdf'
            % check if second argument is of the class 'char'
            if isempty(strmatch('char',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            j = j + 1; % skip argument string in varargin
            filename = varargin{i+1};
         case 'show pdf'
            % check if second argument is of the class 'char'
            if isempty(strmatch('char',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            j = j + 1; % skip argument string in varargin
            filename = varargin{i+1};
            SHOW_PDF = 1;
         case 'offset'
            % check if argument is of the correct class 'double'
            if isempty(strmatch('double',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            if ~min(size(varargin{i+1}) == [1 3])
               error(' Argument for ''offset'' must be a double array with 3 elements.');
            end
            offset = varargin{i+1};
         case 'subplot'
            % check if argument is of the correct class 'double'
            if isempty(strmatch('double',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            if ~min(size(varargin{i+1}) == [1 2])
               error(' Argument for ''subplot'' must be a double array with 2 elements.');
            end
            sub_plot = varargin{i+1};
            LIST_PLOT = 0;   % plot each data in the specified subplot 
         otherwise
            errstr = sprintf('Invalid command ''%s''.',varargin{i});
            error(errstr)
      end
   j = j + 1;
end

if filename & ~isempty(which('temp.ps'))
   delete temp.ps
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% plot analog signal
%--------------------------------

nFigStart = gcf;

if sub_plot(1)
   figure(nFigStart)
   set(gcf,'Color',[1 1 1])
   plot_analog_signal(ST,offset,sub_plot(1))

   if filename & ((length(ST)>1)|~LIST_PLOT)
      print -dpsc2 -append temp.ps 
   end
end



% plot input transformation data
%--------------------------------

if (length(ST)>1)|~LIST_PLOT
   nFigStart = nFigStart + 1;
end


if sub_plot(2)
   for n = 1:length(ST)
      figure(nFigStart)
      set(gcf,'Color',[1 1 1])
      plot_input_data(ST{n},sub_plot(2))
      
      if length(ST)>1
         title(sprintf('Trace %i',n))
      end

      drawnow

      if LIST_PLOT
          if ~mod(n,fix(sub_plot(2)/100))|(n==length(ST))
             if filename
                set(gcf,'PaperPosition',[0.25 0.25 8 10.5]);
                print -dpsc2 -append temp.ps 
             end

             nFigStart = nFigStart + 1;
             sub_plot(2) = fix(sub_plot(2)/10)*10 + 1;
          else
             sub_plot(2) = sub_plot(2) + 1;
          end
      elseif filename
         set(gcf,'PaperPosition',[0.25 0.25 8 10.5]);
         print -dpsc2 -append temp.ps 

         nFigStart = nFigStart + 1;
      else
         nFigStart = nFigStart + 1;
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

