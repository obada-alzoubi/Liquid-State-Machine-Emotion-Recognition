function C = generate(varargin)
%GENERATE   generates a small microcircuit from a small microcircuit template.
%   C = GENERATE(CT) generates a small microcircuit C from a small microcircuit
%   template CT. The actual parameter values of C are drawen from a gauss 
%   distribution with standard deviations specified in CT.neuron_std and 
%   CT.synapse_std. In the variable C this stds are set to zero. Additional
%   the microcircuit is generated with the function CSIM and remains after
%   the function call in the working memory so that it could be simulated with
%   CSIM('simulate',Tmax,Input).
%
%   C = GENERATE(CT1,CT2,...) returns a cell array C with elements as described
%   above, one for each microcircuit CT1, CT2,... . The last microcircuit remains
%   in the working memory and could be simulated with CSIM('simulate',Tmax,Input).
%
%   C = GENERATE(CT1,CT2,...,'readout dt',READOUT_DT) additional specifies the
%   time base READOUT_DT for the signal of the post synaptic current of the output 
%   synapses recorded with the mex recorder. Default value is 1e-3 sec.
%
%   C = GENERATE(CT1,CT2,...,'rndinit',RNDINIT) specifies if the initial membrane
%   potential Vm_init of each neuron is generated randomly or not. If RNDINIT = 1 
%   then
%
%      Vm_init =  rand * (Vm_thresh - Vm_reset)^(1/20) + Vm_reset;
%
%   Default value is 1.
%
%   C = GENERATE(CT1,CT2,...,'Tmax',TMAX) additional specifies the time TMAX for
%   which memory is allocated for the mex recorder. Default value is 1 sec.
%
%   Example:   C = generate(CT{[1 7]},'rndinit',0);
%	       plot(C{:},'show pdf','test.pdf');
%
%              generates microcircuits from the microcircuit templates CT{1} and  
%	       CT{7} with fixed initial conditions and plots the generated circuits
%	       in the pdf file 'test.pdf'.
%
%
%   See also SMALL_MICROCIRCUIT/PLOT, SMALL_MICROCIRCUIT/SMALL_MICROCIRCUIT,
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

idx = strmatch(smc_class_name,class_names,'exact')';

for i = 1:length(idx)
   CT{i} = varargin{idx(i)};
end


% identify command strings
%-------------------------

% default values

TMAX = 1.0;
READOUT_DT = 1e-3;
RNDINIT = 1;

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
         case 'Tmax'
            % check if argument is of the correct class 'double'
            if isempty(strmatch('double',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            if length(varargin{i+1})~=1
               error(' Argument for ''subplot'' must be a double.');
            end
            TMAX = varargin{i+1};
         case 'rndinit'
            % check if argument is of the correct class 'double'
            if isempty(strmatch('double',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            if length(varargin{i+1})~=1
               error(' Argument for ''subplot'' must be a double.');
            end
            RNDINIT = varargin{i+1};
         case 'readout dt'
            % check if argument is of the correct class 'double'
            if isempty(strmatch('double',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            if length(varargin{i+1})~=1
               error(' Argument for ''subplot'' must be a double.');
            end
            READOUT_DT = varargin{i+1};
         otherwise
            errstr = sprintf('Invalid command ''%s''.',varargin{i});
            error(errstr)
      end
   j = j + 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for nCT = 1:length(CT)

   this = CT{nCT};

   neuron_std = this.neuron_std;
   synapse_std = this.synapse_std;
   INidx =  this.INidx;

   i = find(INidx>length(this.neuron));
   INidx(i) = [];

   % initialize csim

   csim('destroy');
   csim('init');


   % set recorder for psc of the output neurons

   psr=csim('create','MexRecorder');
   csim('set',psr,'dt',READOUT_DT);
   csim('set',psr,'Tprealloc',TMAX);
   csim('set',psr,'commonChannels',1);


   % create lif neurons
   %-------------------

   neuron_idx = uint32(zeros(1,length(this.neuron)+length(INidx)));
   for i=1:length(this.neuron)
      if strcmp(this.neuron(1).spec,'LifNeuron')
         n=csim('create','LifNeuron');
         % calculate Vinit before changing the neuron parameters

         this.neuron(i).Vm_init = ~~RNDINIT * rand^(1/20) * ...
    	       (this.neuron(i).Vm_thresh-this.neuron(i).Vm_reset) + this.neuron(i).Vm_reset;


         % add gaussian noise to parameters

         fn = fieldnames(this.neuron_std(i));
         for j = 1:length(fn)
            if ~eval(sprintf('isempty(this.neuron(i).%s)',fn{j}))
               eval(sprintf('MU = this.neuron(i).%s;',fn{j}))
               eval(sprintf('STD2 = this.neuron_std(i).%s;',fn{j}))
               W = abs(gaussrnd(MU,STD2,1,1));
               eval(sprintf('this.neuron(i).%s = W;',fn{j}))

               % that new circuit generation from the template gives the same results
               eval(sprintf('this.neuron_std(i).%s = 0;',fn{j}))
            end
         end

         % set parameters

         csim('set',n,'Vthresh' ,this.neuron(i).Vm_thresh); 
         csim('set',n,'Vreset'  ,this.neuron(i).Vm_reset); 
         csim('set',n,'Vinit'   ,this.neuron(i).Vm_init); 
         csim('set',n,'Vresting',this.neuron(i).Vm_rest);
         csim('set',n,'Trefract',this.neuron(i).Abs_refr); 
         csim('set',n,'Cm'      ,this.neuron(i).Cm);
         csim('set',n,'Rm'	,this.neuron(i).Rm);
         csim('set',n,'Iinject' ,this.neuron(i).I_base); 
         csim('set',n,'Inoise'  ,this.neuron(i).Noise);
      else 
         error('Unknown neuron type!');
      end
      neuron_idx(i)=n;
   end

   % create input neurons

   AINidx = csim('create','AnalogInputNeuron',length(INidx));
   neuron_idx(i+1:end) = AINidx;

   % create synapses
   %----------------

   OSidx = uint32([]);
   synapse_idx = uint32(zeros(1,length(this.synapse)+length(INidx)));

   for i=1:length(this.synapse)


      % add gaussian noise to parameters

      fn = fieldnames(this.synapse_std(i));
      for j = 1:length(fn)
         if ~eval(sprintf('isempty(this.synapse(i).%s)',fn{j}))
            eval(sprintf('SIGN = sign(this.synapse(i).%s);',fn{j}))
            eval(sprintf('MU = this.synapse(i).%s;',fn{j}))
            eval(sprintf('STD2 = this.synapse_std(i).%s;',fn{j}))
            W = SIGN*abs(gaussrnd(MU,STD2,1,1));  	% conserve correct sign
            eval(sprintf('this.synapse(i).%s = W;',fn{j}))

            % that new circuit generation from the template gives the same results
            eval(sprintf('this.synapse_std(i).%s = 0;',fn{j}))
         end
      end

      this.synapse(i).A = this.synapse(i).A * this.Ascale;

      if strcmp(this.synapse(i).spec,'StaticSpikingSynapse')
          s=csim('create','StaticSpikingSynapse');

          csim('set',s,'W',this.synapse(i).A); 
          csim('set',s,'delay',this.synapse(i).Delay); 
          csim('set',s,'tau',this.synapse(i).Tau);
          % csim('set',s,'p',this.synapse(i).p);   doesnt work in current CSIM versions

      elseif strcmp(this.synapse(i).spec,'DynamicSpikingSynapse')
          s=csim('create','DynamicSpikingSynapse');

          csim('set',s,'W',this.synapse(i).A);
          csim('set',s,'delay',this.synapse(i).Delay);
          csim('set',s,'tau',this.synapse(i).Tau);
          % csim('set',s,'p',this.synapse(i).p);   doesnt work in current CSIM versions
          csim('set',s,'U'    ,this.synapse(i).U);
          csim('set',s,'D'    ,this.synapse(i).D);
          csim('set',s,'F'    ,this.synapse(i).F);
          csim('set',s,'u0'   ,this.synapse(i).u_inf);
          csim('set',s,'r0'   ,this.synapse(i).r_inf);
       else
          error('unknown Synapse type!');
       end

       synapse_idx(i)=s;

       % connect synapse to output or post neuron
       if isnan(this.synapse(i).Post_n)
          OSidx(end+1) = s;

	  % create dummy output LifNeuron to connect output synapses
	  ONidx = csim('create','LifNeuron');
	  csim('connect',ONidx,s);
       else
          post = neuron_idx(this.synapse(i).Post_n);
          csim('connect',post,s);
       end

       pre = neuron_idx(this.synapse(i).Pre_n);
       csim('connect',s,pre);
    end

    if OSidx
       csim('connect',psr,OSidx,'psr');
    end


    % create analog input synapses

    s = csim('create','StaticAnalogSynapse',length(INidx));
    csim('set',s,'W',1);
    csim('set',s,'Inoise',0);
    csim('set',s,'delay',0);
    pre = AINidx;
    post = neuron_idx(INidx);
    csim('connect',s,pre);
    csim('connect',post,s);
    synapse_idx(i+1:end) = s;


    if length(CT) == 1
       C  = this;
    else
       C{nCT}  = this;
    end
end

