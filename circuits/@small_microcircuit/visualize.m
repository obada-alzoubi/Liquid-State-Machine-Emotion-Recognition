function [Output]=visualize(varargin)
%VISUALIZE   visualizes the simulation of small microcircuits.
%   VISUALIZE(C,S) simulates the small microcircuits C with the input
%   stimulus S. For each small microcircuit a figure with the outputs of
%   the simulations of all input stimuli S is plotted. The plotted output
%   consists of the pcs traces of output synapses connected to the neurons
%   with indices specified in C.smc.OUTidx. The input stimulus S is a
%   structure with fields
%
%	 'info'	   ... info about the stimulus
%	 'channel' ... input channels
%
%   as for example generated with GENERATE(IT,{'I1'},[1]) from the
%   analog_input_set object IT.
%
%   VISUALIZE(C1,C2,...,S1,S2,...) simulates the small microcircuits C1,
%   C2,... with the input stimuli S1,S2,... . For each small microcircuit
%   a figure with the outputs of the simulations of all input stimuli is
%   plotted. A convenient way to use multiple stimuli is to use a cell
%   arrays
%
%      Example: VISUALIZE( C{[1 3]} , S{[2 3]} )
%
%               visualizes the output of the simulation of the circuits
%               C{1} and C{3} with the input stimuli S{2} and S{3}.
%
%   O = VISUALIZE(C{:},S{:}) returns the output data O of the simulation of
%   each microcircuit with each input stimuli as an NC-by-NS cell array,
%   where NC is the number of small microcircuits and NS is the number of
%   input stimuli. An element of the cell array contains the output cell
%   array R of the CSIM('simulate',Tmax,I) function.
%
%   VISUALIZE(C{:},S{:},'surface','off') plots only the psc traces of the
%   ouput synapses and no surface between the traces.
%
%   VISUALIZE(C{:},S{:},'group','circuit') performs the same simulation as
%   described above but plots for each input stimulus a figure with the
%   outputs of the simulations of all small microcircuits.
%
%   VISUALIZE(C{:},S{:},'dt_sim',DT_SIM) sets the time base DT_SIM of the
%   the simulation. Default value is 1e-4 [sec].
%
%   VISUALIZE(C{:},S{:},'pdf',FILENAME) creates a pdf file FILENAME that
%   contains all matlab figures.
%
%   VISUALIZE(C{:},S{:},'show pdf',FILENAME) additional opens the created
%   pdf file FILENAME with the acrobat reader.
%
%
%   See also SMALL_MICROCIRCUIT/GENERATE, SMALL_MICROCIRCUIT/PLOT,
%	     SMALL_MICROCIRCUIT/SMALL_MICROCIRCUIT, SMALL_MICROCIRCUIT/ADJUST
%
%   Author: Stefan Haeusler, 10/2002, haeusler@igi.tu-graz.ac.at

ALL = -1;
LAST = -2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

smc_class_name = class(varargin{1}); % first argument must be from the small_microcircuit class

for i = 1:nargin
   class_names{i} = class(varargin{i});
end

idx = strmatch('cell',class_names,'exact');
if ~isempty(idx)
   errstr = error(' Function ''visualize'' not defined for arguments of class ''cell''.');
end

% identify small_microcircuits
%-----------------------------

idx = strmatch(smc_class_name,class_names,'exact');
for i = 1:length(idx)
   C{i} = varargin{idx(i)};
end

% identify stimulus structures
%-----------------------------

S = [];

idx = strmatch('struct',class_names,'exact');
for i = 1:length(idx)
   st = varargin{idx(i)};

   str = fieldnames(st);

   switch [str{:}]
      case 'infochannel'
         % stimulus structure
         S{end+1} = st;
      otherwise
         errstr = sprintf('\n  ''%s''',str{:});
         errstr = sprintf(' Function ''visualize'' not defined for arguments of class ''struct'' with fields:%s',errstr);
         error(errstr);
   end
end

if isempty(S)
   error('Not enough input arguments. Stimulus variable not found.')
end


% identify command strings
%-------------------------

% default values

GROUP = 0;
DT_SIM = 1e-4;
SHOW_PDF = 0;
filename = [];
PLOT_SURFACE = 1;
ABSOLUTE_OUTPUT = 1;

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
         case 'group'
            % check if second argument is of the class 'char'
            if isempty(strmatch('char',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            j = j + 1; % skip argument string in varargin

            if ~isempty(strmatch(varargin{i+1},'circuit','exact'));
               GROUP = 1;
            elseif ~isempty(strmatch(varargin{i+1},'input','exact'));
               GROUP = 0;
            else
               errstr = sprintf(' Command ''%s'' not defined for argument ''%s''.',varargin{i},varargin{i+1});
               error(errstr)
            end
            SHOW_PDF = 1;
	 case 'absolute output'
            % check if second argument is of the class 'char'
            if isempty(strmatch('char',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            j = j + 1; % skip argument string in varargin

            if strcmp(varargin{i+1},'on');
               ABSOLUTE_OUTPUT = 1;
            elseif strcmp(varargin{i+1},'off');
               ABSOLUTE_OUTPUT = 0;
            else
               errstr = sprintf(' Command ''%s'' not defined for argument ''%s''.',varargin{i},varargin{i+1});
               error(errstr)
            end
         case 'surface'
            % check if second argument is of the class 'char'
            if isempty(strmatch('char',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            j = j + 1; % skip argument string in varargin

            if strcmp(varargin{i+1},'on');
               PLOT_SURFACE = 1;
            elseif strcmp(varargin{i+1},'off');
               PLOT_SURFACE = 0;
            else
               errstr = sprintf(' Command ''%s'' not defined for argument ''%s''.',varargin{i},varargin{i+1});
               error(errstr)
            end
         case 'dt_sim'
            % check if second argument is of the class 'double'
            if isempty(strmatch('double',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            if ~min(size(varargin{i+1}) == [1 1])
               error(' Argument for ''dt_sim'' must be a double.');
            end

            DT_SIM = varargin{i+1};
         otherwise
            errstr = sprintf('Invalid command ''%s''.',varargin{i});
            error(errstr)
      end
   j = j + 1;
end

if filename & ~isempty(which('temp.ps'))
   delete temp.ps
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN part
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% determine Tmax
%---------------

Tmax = 0;
for nS = 1:length(S)
   Tmax = max(Tmax,S{nS}.info.Tstim);
end

if ~Tmax
   error('Time length of stimuli is zero.')
end



% simulate
%---------

Sc = [];
for nC = 1:length(C)

   if isempty(C{nC}.OUTidx)
      errstr = sprintf(' OUTidx of microcircuit ''%s'' is empty.',C{nC}.name);
      error(errstr);
   end

   csim('destroy')

   % generate circuit from smc template
   generate(C{nC},'readout dt',DT_SIM);

   csim('set','dt',DT_SIM);
   csim('set','randSeed',12345);

   % determine analog input neuron index AINidx
   %-------------------------------------------
   csim_obj = csim('export');
   i = strmatch('AnalogInputNeuron',{csim_obj.object.type},'exact');
   AINidxC = uint32(i-1);

   % set input neuron handles
   %-------------------------

   for nS = 1:length(S)
      % only take allowed input channels
      i = [S{nS}.channel(:).idx];			 % array with input neurons
      j = find( i <= length(C{nC}.INidx));		 % valid input channels
      k = i(j);  					 % Array with input neurons of valid channels

      % only take allowed input neurons
      l = find( k <= length(AINidxC));	 		 % valid input neurons
      j = j(l);					 	 % delete channels with invalid index
      AINidx = AINidxC(k(l));	          		 % get input neuron handles

      % set stimuli and handles

      Sc{nS,nC}.channel = S{nS}.channel(j);		 % because input neuron indices change
							 % for each circuit
      for i = 1:length(AINidx)
         Sc{nS,nC}.channel(i).idx = uint32(AINidx(i));
      end

      % add dummt channel if simulation input is empty
      if isempty(Sc{nS,nC}.channel)
         input = [];
         input.idx = AINidxC(1);
	 input.spiking = 0;
	 input.data = [0.0 0.0];
	 input.dt = Tmax;
      else
         input = Sc{nS,nC}.channel;
      end

      % and simulate
      csim('reset')
      R = csim('simulate',Tmax,input);
      if ABSOLUTE_OUTPUT
         R{1}.data = abs(R{1}.data);
      end
      Output{nS,nC}.R = R;
   end
end


% plot
%-----


if GROUP == 0
   % one circuit & all stimuli per plot

   nFig = gcf;

   for nC = 1:length(C)
      figure(nFig)
      clf
      title(sprintf('Output for %s',C{nC}.name))
      hold on

      % fill to at least 3 traces so surfl has no problems

      k = unique(C{nC}.OUTidx) ;

      if k == ALL
         k = 1:length(C{nC}.neuron);
      elseif k == LAST
         k = length(C{nC}.neuron);
      end
      i = find(k > length(C{nC}.neuron));
      k(i) = [];

      ko = k;
      k = 1:length(k);
      while (length(k) < 3), k(end+1) = k(end); end

      YTick = [];      YTickLabel = [];
      YNameTick = [];  YNameTickLabel = [];
  
      xOfs = 0;

      for nS = 1:length(S)

         y = xOfs + k;

         xOfs = y(end)+3; % set neuron number

         dt_out = Tmax/size(Output{nS,nC}.R{1}.data,2);% set neuron number% set neuron number% set neu% set neu% set neu% set neu% set neu% set neu% set neu% set neuron numberron numberron numberron numberron numberron numberron numberron number
         [X,Y] = meshgrid(dt_out:dt_out:Tmax,y,1);

         % save data for name label
         YNameTick(end+1) = mean(y(1:length(ko)));
         YNameTickLabel{end+1} = sprintf('''%s''',S{nS}.info.name);

	 % plot surface

         if (length(ko) > 1) & PLOT_SURFACE
            h=surfl(X,Y,Output{nS,nC}.R{1}.data(k,:),[90 10],'light');
            colormap([1 0 0;1 0 0]*1)
            set(h(1),'FaceAlpha',[0.5]) 
            material dull
            shading flat
         end

         % plot psc and spikes

         for j = 1:length(ko)
            % set neuron number
            YTick(end+1) =  y(j);
            YTickLabel{end+1} =  sprintf('%i',ko(j));

            % line of psc
            h=plot3(X(j,:),Y(j,:),Output{nS,nC}.R{1}.data(j,:),'k-');

            % points for spikes
            if  ~isempty(Output{nS,nC}.R{2}.idx)
              yi= find(Output{nS,nC}.R{2}.idx==ko(j));
              h=plot3(Output{nS,nC}.R{2}.times(yi),Y(j,1)*ones(size(yi)),...
                 zeros(size(yi)),'b.');
            end
         end
      end

      % set axis
      view([50 80])
      v = axis;
      v(1:4) = [0 Tmax 0 xOfs-2];
      axis(v)

      caxis('auto')

      view([50 80])
      grid on
      xlabel('t [sec]')
      ylabel('Output neuron')
      zlabel(sprintf('I_{syn} [A]'))

      set(gca,'YTick',YTick)
      set(gca,'YTickLabel',YTickLabel)

      % write name labels
      for i = 1: length(YNameTick)
        text(v(2) *1.15,YNameTick(i),v(5),YNameTickLabel{i},'Color',[1 0 0])
      end

      nFig = nFig + 1;
      drawnow

      if filename
         print -dpsc2 -append temp.ps
      end
   end
else
   % one stimulus & all circuits per plot

   nFig = gcf;

   for nS = 1:length(S)
      figure(nFig)
      clf
      title(sprintf('Output for ''%s''',S{nS}.info.name),'Color',[1 0 0])
      hold on
  
      YTick = [];       YTickLabel = [];
      YNameTick = [];   YNameTickLabel = [];
  
      xOfs = 0;

      for nC = 1:length(C)

         % fill to at least 3 traces so surfl has no problems

         k = unique(C{nC}.OUTidx);
         if k == ALL
            k = 1:length(C{nC}.neuron);
         elseif k == LAST
            k = length(C{nC}.neuron);
         end
         i = find(k > length(C{nC}.neuron));
         k(i) = [];

         ko = k;
         k = 1:length(k);
         while (length(k) < 3), k(end+1) = k(end); end

         y = xOfs + k;

         xOfs = y(end)+3; % set neuron number

         dt_out = Tmax/size(Output{nS,nC}.R{1}.data,2);% set neuron number% set neuron number% set neu% set neu% set neu% set neu% set neu% set neu% set neu% set neuron numberron numberron numberron numberron numberron numberron numberron number
         [X,Y] = meshgrid(dt_out:dt_out:Tmax,y,1);

         % save data for name label
         YNameTick(end+1) = mean(y(1:length(ko)));
         YNameTickLabel{end+1} = sprintf('%s',C{nC}.name);

	 % plot surface

         if (length(ko) > 1) & PLOT_SURFACE
            h=surfl(X,Y,Output{nS,nC}.R{1}.data(k,:),[90 10],'light');
            colormap([1 0 0;1 0 0]*1)
            set(h(1),'FaceAlpha',[0.5]) 
            material dull
            shading flat
         end

         % plot psc and spikes

         for j = 1:length(ko)
            % set neuron number
            YTick(end+1) =  y(j);
            YTickLabel{end+1} =  sprintf('%i',ko(j));

            % line of psc
            h=plot3(X(j,:),Y(j,:),Output{nS,nC}.R{1}.data(j,:),'k-');

            % points for spikes
            if  ~isempty(Output{nS,nC}.R{2}.idx)
              yi= find(Output{nS,nC}.R{2}.idx==ko(j));
              h=plot3(Output{nS,nC}.R{2}.times(yi),Y(j,1)*ones(size(yi)),...
                 zeros(size(yi)),'b.');
            end
         end
      end

      % set axis
      view([50 80])
      v = axis;
      v(1:4) = [0 Tmax 0 xOfs-2];
      axis(v)

      caxis('auto')

      view([50 80])
      grid on
      xlabel('t [sec]')
      ylabel('Output neuron')
      zlabel(sprintf('I_{syn} [A]'))

      set(gca,'YTick',YTick)
      set(gca,'YTickLabel',YTickLabel)

      % write name labels
      for i = 1: length(YNameTick)
        text(v(2) *1.15,YNameTick(i),v(5),YNameTickLabel{i})
      end

      nFig = nFig + 1;
      drawnow

      if filename
         print -dpsc2 -append temp.ps
      end

   end

end


% pdf options 
%------------

if filename
   eval(sprintf('!ps2pdf temp.ps %s',filename))

   if SHOW_PDF
      fprintf('Close Acrobat Reader to proceed!\n')
      eval(sprintf('!acroread %s',filename))
   end

   delete temp.ps
end


