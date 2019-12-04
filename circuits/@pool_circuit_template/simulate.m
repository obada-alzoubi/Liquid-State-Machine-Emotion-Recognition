function [Output]=simulate(varargin)
%SIMULATE   simulates pool circuit templates.
%   R = SIMULATE(P,C,S) simulates the circuit C generated from a
%   pool circuit template P with the input stimulus S. The input
%   stimulus S is a structure with fields
%
%	 'info'	    ... info about the stimulus
%	 'channel'  ... input channels
%
%   as for example generated with GENERATE(IT,{'I1'},[1]) from the
%   ANALOG_INPUT_SET object IT. The circuit C is a structure with fields
%
%        'template'     ... pool circuit template P
%	 'circuit'      ... circuit object
%	 'circuit_info' ... additional info about the circuit object
%	 'csimNet'      ... csim export structure of the circuit
%
%   as generated with C = GENERATE(P).
%
%   R = SIMULATE(P,C1,C2,...,S1,S2,...) simulates the pool circuit templates
%   C1, C2, ... with the input stimuli S1,S2,... . (Remark: The
%   contents of P is irrelevant for the function call)
%
%   The circuit response R of the simulation of each circuit with each
%   input stimuli is an NS-by-NC cell array, where NC is the number of
%   pool circuit templates and NS is the number of input stimuli.
%   An element of the cell array contains a struct with the fields
%
%	 'R'      ... spike response returned by CSIM('simulate',Tmax,I)
%	 'S'      ... stimulus, e.g. S1.
%	 'C'      ... circuit structure, e.g. C1
%
%
%   See also POOL_CIRCUIT_TEMPLATE/GENERATE
%            POOL_CIRCUIT_TEMPLATE/PLOT
%	     POOL_CIRCUIT_TEMPLATE/POOL_CIRCUIT_TEMPLATE
%            POOL_CIRCUIT_TEMPLATE/ADJUST
%	     POOL_CIRCUIT_TEMPLATE/MODEL2STATES
%            POOL_CIRCUIT_TEMPLATE/STATES2MODEL
%	     POOL_CIRCUIT_TEMPLATE/VISUALIZE
%
%   Author: Stefan Haeusler, 5/2003, haeusler@igi.tu-graz.ac.at

ALL = -1;
LAST = -2;

global VERBOSE_LEVEL

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

smc_class_name = class(varargin{1}); % first argument must be from the POOL_CIRCUIT_TEMPLATE class

for i = 1:nargin
   class_names{i} = class(varargin{i});
end

idx = strmatch('cell',class_names,'exact');
if ~isempty(idx)
   errstr = error(' Function ''simulate'' not defined for arguments of class ''cell''.');
end


% identify stimulus & pool circuit template structures
%----------------------------------------------

S = [];
C = [];

idx = strmatch('struct',class_names,'exact');
for i = 1:length(idx)
   st = varargin{idx(i)};

   str = fieldnames(st);
   switch [str{:}]
      case {'infochannel','channelinfo'}
         % stimulus structure
         S{end+1} = st;
      case {'templatecircuitcsimNet','templatecircuitcircuit_infocsimNet'}
         % pool circuit template structure
         C{end+1} = st;
      otherwise
         errstr = sprintf('\n  ''%s''',str{:});
         errstr = sprintf(' Function ''simulate'' not defined for arguments of class ''struct'' with fields:%s',errstr);
         error(errstr);
   end
end

if isempty(S)
   error('Not enough input arguments. Stimulus variable not found.')
end
if isempty(C)
   error('Not enough input arguments. Pool circuit template variable not found.')
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

   % generate circuit from smc template
   csim('destroy')
   csim('import',C{nC}.csimNet)


   % set recorder properties
   %------------------------

   rec = get(C{nC}.circuit,'recorder');
   csim('set',[rec.idx],'commonChannels',0);


   % determine analog input neuron index AINidx
   %-------------------------------------------

   pool = get(C{nC}.circuit,'pool');
   AINidxC = strmatch('AnalogInputNeuron',{pool.type},'exact');
   SINidxC = strmatch('SpikingInputNeuron',{pool.type},'exact');

   AINidx = [pool(sort([AINidxC SINidxC])).neuronIdx];


   % set input handles
   %------------------

   for nS = 1:length(S)

      if VERBOSE_LEVEL
         fprintf('%5i/%5i\n',nS,length(S))
         %fprintf('\b\b\b\b\b\b\b\b\b\b\b%5i/%5i',nS,length(S))
      end

      % only take allowed input channels

      % if idx not existing then asume simple increasing index
      try
         i = [S{nS}.channel(:).idx];			 % array with channel numbers
      catch
         i = [1:length(S{nS}.channel)];
      end
      j = find( i <= length(AINidx));		         % valid input channels
      k = i(j);  					 % Array with valid channels

      % set stimuli and handles

      Sc{nS,nC}.channel = S{nS}.channel(j);		 % because input neuron indices change
							 % for each circuit
      for i = 1:length(j)
         Sc{nS,nC}.channel(i).idx = uint32(AINidx(k(i)));
      end

      % add dummy channel if simulation input is empty
      if isempty(Sc{nS,nC}.channel)
         input = [];
         input.idx = AINidx(1);
         it = csim('get',input.idx);
         if strcmp(it.classname,'SpikingInputNeuron')
   	    input.spiking = 1;
	    input.data = [];
	    input.dt = -1;
         elseif strcmp(it.classname,'AnalogInputNeuron')
   	    input.spiking = 0;
	    input.data = [0.0 0.0];
	    input.dt = Tmax;
         end
      else
         input = Sc{nS,nC}.channel;
      end

      % fill all analog input channels beyond Tmax
      
      for nI = 1:length(input)
         if (input(nI).spiking == 0)
            input(nI).data = [input(nI).data input(nI).data(:,end)];
         end
      end


      % and simulate

      rand('state',sum(100*clock))

      if (0)
         disp('@pool_circuit_template/simulate.m: randSeed set to specified value.')
         csim('set','randSeed',get(C{nC}.template,'randSeedConn')); 
      else
         csim('set','randSeed',randseed); % Inoise should be different
      end

      csim('reset')

      Output{nS,nC}.R = csim('simulate',Tmax,input);

      Output{nS,nC}.S = S{nS};
      Output{nS,nC}.C = C{nC};
      
      for nR = 1:length(Output{nS,nC}.R)
         Output{nS,nC}.R{nR}.Tsim = Tmax;
      end
   end
end

