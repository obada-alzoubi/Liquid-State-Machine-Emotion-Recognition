function plot(varargin)
%PLOT Plots a small_microcircuit object.
%   PLOT(CT) plots a matlab figure of the small_microcircuit CT in
%   the current figure GCF.
%
%   PLOT(CT1,CT2,...) plots matlab figures of the small_microcircuits 
%   CT1, CT2 etc. starting with the current figure GCF. Each 
%   microcircuit is plotted in its own figure with increasing figure
%   number.
%
%   PLOT(CT,...,'pdf',FILENAME) plots matlab figures and creates a 
%   pdf file FILENAME.
%
%   PLOT(CT,...,'show pdf',FILENAME) additional opens the created pdf file 
%   FILENAME with the acrobat reader.
%
%   PLOT(CT,...,'subplot',SUBPLOT) additional specifies the subplots in which the 
%   three parts: graphic, neuron parameters and synapse parameters are plotted.
%
%   Example:  plot(CT{[1 3]},'subplot',[0 312 313])
%
%	      plots for the small mircocircuit templates CT{1} and CT{3} no 
%	      graphic part, the neuron parameters in subplot 312 and the synapse
%	      parameters in subplot 313.
%
%
%   See also SMALL_MICROCIRCUIT/GENERATE, SMALL_MICROCIRCUIT/SMALL_MICROCIRCUIT
%            SMALL_MICROCIRCUIT/VISUALIZE, SMALL_MICROCIRCUIT/ADJUST
%
%   Author: Stefan Haeusler, 10/2002, haeusler@igi.tu-graz.ac.at


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

smc_class_name = class(varargin{1}); % first argument must be from the small_microcircuit class

for i = 1:nargin
   class_names{i} = class(varargin{i});
end

% identify small_microcircuits
%-----------------------------

idx = strmatch(smc_class_name,class_names,'exact');
for i = 1:length(idx)
   CT{i} = varargin{idx(i)};
end

% identify command strings
%-------------------------

% default values


SHOW_PDF = 0;
filename = [];
sub_plot = [311 312 313];

str = [];
idx = strmatch('char',class_names,'exact');
j = 1;
while j <= length(idx)
      i = idx(j);

      % check if second argument is present
      if (i+1)>nargin
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
         case 'subplot'
            % check if argument is of the correct class 'double'
            if isempty(strmatch('double',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            if ~min(size(varargin{i+1} == [1 3]))
               error(' Argument for ''subplot'' must be a double array with 3 elements.');
            end
            sub_plot = varargin{i+1};
         otherwise
            errstr = sprintf('Invalid command ''%s''.',varargin{i});
            error(errstr)
      end
   j = j + 1;
end

if filename & ~isempty(which('temp.ps'))
   delete temp.ps
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% graphical representation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nFigStart = gcf;

for nCT = 1:length(CT)

   nFig = nFigStart+nCT-1;
   figure(nFig);
   clf;
   set(gcf,'Color',[1 1 1])

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Plot graphic
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   if sub_plot(1)
      plot_graphic_data(CT{nCT},sub_plot(1))
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Neuron data
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   if sub_plot(2)
      plot_neuron_data(CT{nCT},sub_plot(2)) 
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Synapse data
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   if sub_plot(3)
      for i = 1:length(CT{nCT}.synapse)
         CT{nCT}.synapse(i).A = CT{nCT}.synapse(i).A * CT{nCT}.Ascale;
      end 
      plot_synapse_data(CT{nCT},sub_plot(3)) 
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % general figure options
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   drawnow
   set(gcf,'PaperPosition',[0.25 0.25 8 10.5]);

   if filename
      print -dpsc2 -append temp.ps
   end
end

% pdf options 

if filename
   eval(sprintf('!ps2pdf temp.ps %s',filename))

   if SHOW_PDF
      fprintf('Close Acrobat Reader to proceed!\n')
      eval(sprintf('!acroread %s',filename))
   end

   delete temp.ps
end

