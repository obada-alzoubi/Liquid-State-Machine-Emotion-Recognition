function [C] = generate(varargin)
%GENERATE   generates a circuit from a pool circuit template.
%   C = GENERATE(CT) generates a circuit C from a pool circuit
%   template CT. The circuit is generated with the class methods of the
%   circuit class specified in CT.circuit under usage of the function CSIM.
%   The structure C has the fields
%
%        'template' ... pool circuit template
%	 'circuit'  ... generated circuit object
%	 'csimNet'  ... csim export structure of the circuit
%
%   The circuit remains after the function call in the working memory so
%   that it could be simulated with CSIM('simulate',Tmax,Input).
%
%   C = GENERATE(CT1,CT2,...) returns a cell array C with elements as described
%   above, one for each circuit CT1, CT2,... . The last circuit remains
%   in the working memory and could be simulated with CSIM('simulate',Tmax,Input).
%
%
%   See also POOL_CIRCUIT_TEMPLATE/SIMULATE
%            POOL_CIRCUIT_TEMPLATE/PLOT
%	     POOL_CIRCUIT_TEMPLATE/POOL_CIRCUIT_TEMPLATE
%            POOL_CIRCUIT_TEMPLATE/ADJUST
%	     POOL_CIRCUIT_TEMPLATE/MODEL2STATES
%            POOL_CIRCUIT_TEMPLATE/STATES2MODEL
%	     POOL_CIRCUIT_TEMPLATE/VISUALIZE
%
%   Author: Stefan Haeusler, 5/2003, haeusler@igi.tu-graz.ac.at

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

this_class_name = class(varargin{1}); % first argument must be from the POOL_CIRCUIT_TEMPLATE class

for i = 1:nargin
   class_names{i} = class(varargin{i});
end

% identify POOL_CIRCUIT_TEMPLATEs
%-----------------------------

idx = strmatch(this_class_name,class_names,'exact')';

for i = 1:length(idx)
   CT{i} = varargin{idx(i)};
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize some constants

global VERBOSE_LEVEL

ARGIN_ID = 'argin';

% initialize random number generator

csim('set','randSeed',rand*1e6);


for nCT = 1:length(CT)

   this = CT{nCT};

   % delete invalid input channel indices

   INidx = this.INidx;
   i = find(INidx>length(this.pool));
   INidx(i) = [];

   % initialize csim

   csim('destroy');
   csim('init');

   % create circuit object
   %----------------------

   mc = eval(this.circuit);


   % set simulation time step
   %-------------------------

   csim('set','dt',this.dt_sim);
   mc = set(mc,'dt_sim',this.dt_sim);


   % create pools
   %--------------

   for nP = 1:length(this.pool)

      % set pool parameter as default parameters for mc

      commands = fieldnames(this.pool(nP));
      cIdx = strmatch('parameters',commands,'exact');
      if isempty(cIdx)
         error('Field ''parameters'' in struct array ''pool'' must exist.')
      end

      if isempty(this.pool(nP).parameters)
         error('Field ''parameters'' in struct array ''pool'' must not be empty.')
      end

      def = get(mc,'def');
      def.pool = this.pool(nP).parameters;
      mc = set(mc,'def',def);


      % execute pool generation commands, each specified by a field in this.pool(nP)

      cIdx = strmatch('add',commands,'exact');

      commands = commands(cIdx);

      for cIdx = 1:length(commands)

         % create command string for this command
	 % each argument is a field in the command structure

         com_str = sprintf('%s(mc',commands{cIdx});

	 % read arguments of this command
	 command = getfield(this.pool(nP),commands{cIdx});
	 arguments = fieldnames(command);

         % NOTE: argin shouldn't be deleted until command is executed
	 argin{1} = [];   % input arguments
	 arginIdx = 0; % number of input arguments (could be different from length(arguments))


	 for argIdx = 1:length(arguments)
	    if strncmp(arguments{argIdx},ARGIN_ID,length(ARGIN_ID))
	       % input argument without preceding namefield

	       c = getfield(command,arguments{argIdx});
	       Idx = arginIdx + 1;
	       argin{Idx} = c;

	       add_str = sprintf(',argin{%i}',Idx);
	       arginIdx = Idx(end);
	    else
	       % input argument with preceding name field

	       arginIdx = arginIdx + 1;
	       argin{arginIdx} = getfield(command,arguments{argIdx});

	       % if argument is empty only output name field (e.g. add(mc,'Pool',...));
	       if isempty(argin{arginIdx})
	          add_str = sprintf(',''%s''',arguments{argIdx});
	       else
	          add_str = sprintf(',''%s'',argin{%i}',arguments{argIdx},arginIdx);
	       end
	    end
	    com_str = [com_str add_str];
	 end

	 % finish command string

	 com_str = [com_str ');'];

	 % execute command
         
         if VERBOSE_LEVEL
            fprintf('\n%s\n',com_str);
         end
         [mc] = eval(com_str);
      end
   end

   % create pool connections
   %-------------------------

   for nC = 1:length(this.conn)

      % set conn parameter as default parameters for mc
      commands = fieldnames(this.conn(nC));
      cIdx = strmatch('parameters',commands,'exact');
      if isempty(cIdx)
         error('Field ''parameters'' in struct array ''conn'' must exist.')
      end
      
      if isempty(this.conn(nC).parameters)
         error('Field ''parameters'' in struct array ''conn'' must not be empty.')
      end

      def = get(mc,'def');
      def.conn = this.conn(nC).parameters;
      mc = set(mc,'def',def);

      % execute conn generation commands, each specified by a field in this.conn(nC)

      commands(cIdx) = []; % clear parameter field

      for cIdx = 1:length(commands)

         % create command string for this command
	 % each argument is a field in the command structure

         com_str = sprintf('%s(mc',commands{cIdx});

	 % read arguments of this command
	 command = getfield(this.conn(nC),commands{cIdx});
	 if isempty(command), break, end
	 arguments = fieldnames(command);

         % NOTE: argin shouldn't be deleted until command is executed
	 argin{1} = [];   % input arguments
	 arginIdx = 0; % number of input arguments (could be different from length(arguments))

	 for argIdx = 1:length(arguments)
	    if strncmp(arguments{argIdx},ARGIN_ID,length(ARGIN_ID))
	       % input argument without preceding namefield

               c = getfield(command,arguments{argIdx});
	       Idx = arginIdx + 1;
	       argin{Idx} = c;

	       add_str = sprintf(',argin{%i}',Idx);
	       arginIdx = Idx(end);
	    else
	       % input argument with preceding name field

	       arginIdx = arginIdx + 1;
	       argin{arginIdx} = getfield(command,arguments{argIdx});

	       % if argument is empty only output name field (e.g. add(mc,'randConn',...));
	       if isempty(argin{arginIdx})
	          add_str = sprintf(',''%s''',arguments{argIdx});
	       else
	          add_str = sprintf(',''%s'',argin{%i}',arguments{argIdx},arginIdx);
	       end
	    end
	    com_str = [com_str add_str];
	 end

	 % finish command string

	 com_str = [com_str ');'];

         % execute command
         if VERBOSE_LEVEL
            fprintf('\n%s\n',com_str);
         end 
         [mc] = eval(com_str);
      end
   end

   % create input connections
   %--------------------------

   % create input neurons (for each input channel one)

   AINidx = [];
   for nINidx = 1:length(this.input)
     if ~isempty(findstr(this.input(nINidx).parameters.type,'Analog'))
        [mc,AINidx(end+1)] = add(mc,'Pool','origin',[1 1 nINidx],'size',[1 1 1],'type','AnalogInputNeuron','frac_EXC',1);
     else
        [mc,AINidx(end+1)] = add(mc,'Pool','origin',[1 1 nINidx],'size',[1 1 1],'type','SpikingInputNeuron','frac_EXC',1);
     end
   end

   % create input connections

   for nC = 1:length(this.input)

      % set input parameter as default parameters for mc

      commands = fieldnames(this.input(nC));
      cIdx = strmatch('parameters',commands,'exact');
      if isempty(cIdx)
         error('Field ''parameters'' in struct array ''input'' must exist.')
      end

      if isempty(this.input(nC).parameters)
         error('Field ''parameters'' in struct array ''input'' must not be empty.')
      end

      def = get(mc,'def');
      def.conn = this.input(nC).parameters;
      mc = set(mc,'def',def);

      % execute input conn generation commands, each specified by a field in this.input(nC)

      commands(cIdx) = []; % clear parameter field

      for cIdx = 1:length(commands)

         % create command string for this command
	 % each argument is a field in the command structure

         com_str = sprintf('%s(mc',commands{cIdx});

	 % read arguments of this command
	 command = getfield(this.input(nC),commands{cIdx});
	 arguments = fieldnames(command);

	 % Only for input connection commands: set src and dest
	 rfcIdx = strmatch(arguments{1},{'randConn' 'faninConn'},'exact');

	 if ~isempty(rfcIdx)
	    % delete dest and src fields if they exist
	    destIdx = strmatch('dest',arguments,'exact');
	    srcIdx = strmatch('src',arguments,'exact');

            % destination could be set manually to overwrite input pool destination
            if ~isempty(destIdx)
   	       command.dest =  getfield(command,'dest');
            else
   	       command.dest = this.INidx(nC);  % handle of target pool
            end 

	    command.src = AINidx(nC);       % handle on input neuron

	    arguments([destIdx srcIdx]) = [];

	    % set correct dest and src fields
	    arguments = {arguments{1} 'dest' 'src' arguments{2:end}};
%	    arguments = {arguments{1:rfcIdx} 'dest' 'src' arguments{rfcIdx+1:end}};

	 end

         % NOTE: argin shouldn't be deleted until command is executed
	 argin{1} = [];   % input arguments
	 arginIdx = 0; % number of input arguments (could be different from length(arguments))

	 for argIdx = 1:length(arguments)
	    if strncmp(arguments{argIdx},ARGIN_ID,length(ARGIN_ID))
	       % input argument without preceding namefield

	       c = getfield(command,arguments{argIdx});
	       Idx = arginIdx + 1;
	       argin{Idx} = c;

	       add_str = sprintf(',argin{%i}',Idx);
	       arginIdx = Idx(end);
	    else
	       % input argument with preceding name field

	       arginIdx = arginIdx + 1;
	       argin{arginIdx} = getfield(command,arguments{argIdx});

	       % if argument is empty only output name field (e.g. add(mc,'randConn',...));
	       if isempty(argin{arginIdx})
	          add_str = sprintf(',''%s''',arguments{argIdx});
	       else
	          add_str = sprintf(',''%s'',argin{%i}',arguments{argIdx},arginIdx);
	       end
	    end
	    com_str = [com_str add_str];
	 end

	 % finish command string

	 com_str = [com_str ');'];
         
	 % execute command
         if VERBOSE_LEVEL
            fprintf('\n%s\n',com_str);
         end
         [mc] = eval(com_str);
      end
   end


   % modify pools
   %--------------

   for nP = 1:length(this.pool)

      % set pool parameter as default parameters for mc

      commands = fieldnames(this.pool(nP));

      % execute pool modification commands, each specified by a field in this.pool(nP)

      cIdx = strmatch('parameters',commands,'exact');
      cIdx(2) = strmatch('add',commands);
      commands(cIdx) = []; % clear parameter field

      for cIdx = 1:length(commands)

         % create command string for this command
	 % each argument is a field in the command structure

         com_str = sprintf('%s(mc',commands{cIdx});
	 
	 % read arguments of this command
	 command = getfield(this.pool(nP),commands{cIdx});
	 arguments = fieldnames(command);

         % NOTE: argin shouldn't be deleted until command is executed
	 argin{1} = [];   % input arguments
	 arginIdx = 0; % number of input arguments (could be different from length(arguments))

	 for argIdx = 1:length(arguments)
	    if strncmp(arguments{argIdx},ARGIN_ID,length(ARGIN_ID))
	       % input argument without preceding namefield

	       c = getfield(command,arguments{argIdx});
	       Idx = arginIdx + 1;
	       argin{Idx} = c;

	       add_str = sprintf(',argin{%i}',Idx);
	       arginIdx = Idx(end);
	    else
	       % input argument with preceding name field

	       arginIdx = arginIdx + 1;
	       argin{arginIdx} = getfield(command,arguments{argIdx});

	       % if argument is empty only output name field (e.g. add(mc,'Pool',...));
	       if isempty(argin{arginIdx})
	          add_str = sprintf(',''%s''',arguments{argIdx});
	       else
	          add_str = sprintf(',''%s'',argin{%i}',arguments{argIdx},arginIdx);
	       end
	    end
	    com_str = [com_str add_str];
	 end

	 % finish command string

	 com_str = [com_str ');'];

	 % execute command
         if VERBOSE_LEVEL
            fprintf('\n%s\n',com_str);
         end
         [mc] = eval(com_str);
      end
   end


   % create recorders
   %------------------

   % create input connections

   for nRec = 1:length(this.recorder)
    for nO = 1:length(this.OUTidx)

      % create command string for this command
      % each argument is a field in the command structure

      com_str = sprintf('record(mc,''Pool'',%i',this.OUTidx(nO));

      % read arguments of this command

      command = this.recorder(nRec);
      arguments = fieldnames(command);

      % NOTE: argin shouldn't be deleted until command is executed
      argin{1} = [];   % input arguments
      arginIdx = 0; % number of input arguments (could be different from length(arguments))

      for argIdx = 1:length(arguments)
	 if strncmp(arguments{argIdx},ARGIN_ID,length(ARGIN_ID))
	    % input argument without preceding namefield

	    c = getfield(command,arguments{argIdx});
	    Idx = arginIdx + 1;
	    argin{Idx} = c;

	    add_str = sprintf(',argin{%i}',Idx);
	    arginIdx = Idx(end);
	 else
	    % input argument with preceding name field

	    arginIdx = arginIdx + 1;
	    argin{arginIdx} = getfield(command,arguments{argIdx});

	    % if argument is empty only output name field (e.g. add(mc,'randConn',...));
	    if isempty(argin{arginIdx})
	       add_str = sprintf(',''%s''',arguments{argIdx});
	    else
	       add_str = sprintf(',''%s'',argin{%i}',arguments{argIdx},arginIdx);
	    end
	 end
         com_str = [com_str add_str];
      end

      % finish command string

      com_str = [com_str ');'];

      % execute command
      if VERBOSE_LEVEL
         fprintf('\n%s\n',com_str);
      end
      [mc] = eval(com_str);

    end
   end

   %
   % get info about the exact paramaters of the generated circuit
   %

   mc_info = [];
   if VERBOSE_LEVEL
      fprintf('\nWARNING: field ''mc_info'' cleared!\n')
   end 
%   mc_info = get_additional_circuit_info(mc,CT{nCT});

   csim('reset')  % so that all lookup tables are calculated only once

   if length(CT) > 1
      C{nCT}.template = CT{nCT};
      C{nCT}.circuit = mc;
      C{nCT}.circuit_info = mc_info;
      C{nCT}.csimNet = csim('export');
   else
      C.template = CT{nCT};
      C.circuit = mc;
      C.circuit_info = mc_info;
      C.csimNet = csim('export');
   end
end
