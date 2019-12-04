function [C]=adjust(varargin)
%ADJUST   adjusts pool circuit template parameters.
%   R = ADJUST(C,S1,S2,...,FN1,FP1,FN2,FP2,...) finds the synaptic
%   parameters A, U, D and F of the pool circuit template C that minimize the
%   cost functions FN1,FN2,... with their respective parameters FP1,FP2,...
%   for a given set of input stimuli S1, S2,... by means of adaptive
%   simulated annealing. The optimized pool circuit template is returned in R.
%
%   The minimized total cost value is the sum of all single cost values of
%   the cost functions FN1,FN2,... . At least one cost function must be
%   specified. Valid cost functions and parameters are:
%
%   ADJUST(C,S1,S2,...,'mean firing rate',[FR1 CV1; FR2 CV2;...]) tries to 
%   set the mean firing rate of neuron 1 to FR1, of neuron 2 to FR2 ... .   
%   The cost value is the sum of the squares of the difference between the 
%   actual firing rate AFR and the desired value FR of each neuron times the 
%   value CV:
%
%         cost_value = CV1*(FR1-AFR1)^2 + CV2*(FR2-AFR2)^2 + ...
%
%   For neurons with indices higher than the number of rows in the parameter
%   matrix the values of the last row in the matrix are taken. If FR or CV
%   are NaN the parameters of the respective neurons are not optimized.
%
%   ADJUST(C,S1,S2,...,'stop',[T1 CV1; T2 CV2;...]) If the last spike ST1 of
%   neuron 1 occurs after the time T1 the value CV1 is added to the cost 
%   value and so on ...:
%
%   	  cost_value = CV1*(ST1 > T1) + CV2*(ST2 > T2) + ...
%
%   For neurons with indices higher than the number of rows in the parameter
%   matrix the values of the last row in the matrix are taken.If T or CV
%   are NaN the parameters of the respective neurons are not optimized.
%
%   ADJUST(C,S1,S2,...,'anti correlation',[N1 M1 CV1; N2 M2 CV2;...]) The
%   correlation of the psc traces PSCN1 and PSCM1 of the output synapses 
%   connected to the neurons with indices N1 and M1 is added to the cost
%   value and so on ...:
%
%   	  cost_value = CV1*corr(PSCN1,PSCM1) + CV2*corr(PSCN2,PSCM2) + ...
%
%   ADJUST(C,S1,S2,...,'algorithm','asamin',PropertyName1,PropertyValue1,...)
%   uses the fit algorithm ASA for the optimization and sets the specified 
%   options PropertyName to the respective PropertyValues. Type
%
%         help pool_circuit_template/private/asamin
%
%   for a list of valid options and further information. Default
%   'temperature_ratio_scale' is 9e-1.
%
%   ADJUST(C,S1,S2,...,'algorithm','fmincon',PropertyName1,PropertyValue1,...)
%   uses the fit algorithm FMINCON for the optimization and sets the specified 
%   options PropertyName to the respective PropertyValues. Type
%
%      help fmincon
%
%   for a list of valid options and further information.
%
%   ADJUST(C,S1,S2,...,'synapses',[S1 S2 S3 ...],...) optimizes only the 
%   parameters of synapses with indices S1, S2, S3, ... (see plot(C) for
%   synapse indices).
%
%
%   See also POOL_CIRCUIT_TEMPLATE/GENERATE, POOL_CIRCUIT_TEMPLATE/VISUALIZE,
%	     POOL_CIRCUIT_TEMPLATE/POOL_CIRCUIT_TEMPLATE, POOL_CIRCUIT_TEMPLATE/PLOT
%
%   Author: Stefan Haeusler, 3/2003, haeusler@igi.tu-graz.ac.at

ALL = -1;
LAST = -2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

smc_class_name = class(varargin{1}); % first argument must be from the pool_circuit_template class

for i = 1:nargin
   class_names{i} = class(varargin{i});
end

idx = strmatch('cell',class_names,'exact');
if ~isempty(idx)
   errstr = error(' Function ''adjust'' not defined for arguments of class ''cell''.');
end

% identify pool_circuit_template
%-----------------------------

idx = strmatch(smc_class_name,class_names,'exact');
for i = 1:length(idx)
   C{i} = varargin{idx(i)};
end

if length(C) ~= 1
   errstr = error(' Function ''adjust'' only defined for a single pool circuit template.');
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
         errstr = sprintf(' Function ''adjust'' not defined for arguments of class ''struct'' with fields:%s',errstr);
         error(errstr);
   end
end

if isempty(S)
   error('Not enough input arguments. Stimulus variable not found.')
end


% identify command strings
%-------------------------

asamin_option_str = {'rand_seed' 'test_in_cost_func' 'use_rejected_cost' 'asa_out_file' ...
                     'limit_acceptances' 'limit_generated' 'limit_invalid' 'accepted_to_generated_ratio' ...
                     'cost_precision' 'maximum_cost_repeat' 'number_cost_samples' ...
                     'temperature_ratio_scale' 'cost_parameter_scale' 'temperature_anneal_scale' ...
                     'include_integer_parameters' 'user_initial_parameters' 'sequential_parameters' ...
                     'initial_parameter_temperature' 'acceptance_frequency_modulus' ...
                     'generated_frequency_modulus' 'reanneal_cost' 'reanneal_parameters' 'delta_x'};

fmincon_option_str = {'Display' 'TolX' 'TolFun' 'TolCon' 'DerivativeCheck' 'Diagnostics' 'GradObj' ...
                      'GradConstr' 'Hessian' 'MaxFunEvals' 'MaxIter' 'DiffMinChange' 'DiffMaxChange' ...
                      'LargeScale' 'MaxPCGIter' 'PrecondBandWidth' 'TolPCG' 'TypicalX' 'Hessian' ...
                      'HessMult' 'HessPattern'};


% default values

SynapsesToFit = ALL;
DT_SIM = 1e-4;
criterion = [];
ALGORITHM = 'asamin';

FitPropertyName = [];
FitPropertyValue= [];

crit_par = [];




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
         case 'synapses'
            % check if second argument is of the class 'double'
            if isempty(strmatch('double',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            SynapsesToFit = varargin{i+1};
            SynapsesToFit = SynapsesToFit(:);
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
         case 'algorithm'
            % check if second argument is of the class 'double'
            if isempty(strmatch('char',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            switch varargin{i+1}
               case 'asamin'
                   ALGORITHM = 'asamin';
                   option_str = asamin_option_str;
               case 'fmincon'
                   ALGORITHM = 'fmincon';
                   option_str = fmincon_option_str;
               otherwise
                  errstr = sprintf('Fit algorithm ''%s'' unknown.',varargin{i+1});
                  error(errstr);
            end

            j = j+1; % cause algorithm argument is a string

            % optional fit parameters
            osi  = NaN;
            while ~isempty(strmatch('char',class(varargin{i+2}),'exact')) & ~isempty(osi)  
               osi = strmatch(varargin{i+2},option_str,'exact');
               if ~isempty(osi)
	          FitPropertyName{end+1} = varargin{i+2};
	          FitPropertyValue{end+1} = varargin{i+3};

                  if ~isempty(strmatch('char',class(varargin{i+3}),'exact'))
                     j = j+1; % cause argument is a string
                  end
                  
                  j = j+1; % cause argument is a string
                  i = i+2;
               end
            end
         case 'mean firing rate'
 
            % check if second argument is of the class 'double'
            if isempty(strmatch('double',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            if size(varargin{i+1},2) ~= 2
               errstr = sprintf(' Argument for ''%s'' must be a matrix with 2 columns.',varargin{i});
               error(errstr);
            end

	    criterion{end+1} = 'mfr';
            crit_par{end+1} = varargin{i+1};
         case 'anti correlation'
 
            % check if second argument is of the class 'double'
            if isempty(strmatch('double',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            if (size(varargin{i+1},2) ~= 3)
               errstr = sprintf(' Argument for ''%s'' must be a matrix with 3 columns.',varargin{i});
               error(errstr);
            end

	    criterion{end+1} = 'anticorr';
            crit_par{end+1} = varargin{i+1};
         case 'stop'
 
            % check if second argument is of the class 'double'
            if isempty(strmatch('double',class(varargin{i+1}),'exact'))
               errstr = sprintf(' Command ''%s'' not defined for arguments of class ''%s''.',varargin{i},class(varargin{i+1}));
               error(errstr);
            end

            if size(varargin{i+1},2) ~= 2
               errstr = sprintf(' Argument for ''%s'' must be a matrix with 2 columns.',varargin{i});
               error(errstr);
            end

	    criterion{end+1} = 'stop';
            crit_par{end+1} = varargin{i+1};
         otherwise
            errstr = sprintf('Invalid command ''%s''.',varargin{i});
            error(errstr)
      end
   j = j + 1;
end

if isempty(criterion)
   error('No adjustment criterion specified.')
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



% set inputs
%-----------

% for the cost function routine
evalin('base','clear csim_obj; global csim_obj; csim_obj = [];')
global csim_obj


Sc = [];
for nC = 1:length(C)

   if isempty(C{nC}.Ascale)|(C{nC}.Ascale==0)
      errstr('Scaling parameter of the synaptic strength of circuit ''%s'' is invalid.',C{nC}.name);
      error(errstr)
   end

   csim('destroy')

   % That for the cost function routine the meax recorder is set:
   % record from all liquid neurons
   C{nC}.OUTidx = -1; % ALL

   % generate circuit from smc template
   generate(C{nC});

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
   end
end

% fit
%====

% encode synaptic parameters

[xinit,xl,xu,xt] = encode_syn_parameter(C,SynapsesToFit);

% variables for the cost function

fitparam.criterion = criterion;
fitparam.crit_par = crit_par;
fitparam.Tmax = Tmax;
fitparam.C = C;
fitparam.DT_SIM = DT_SIM;
fitparam.Sc = Sc;
fitparam.SynapsesToFit = SynapsesToFit;


switch ALGORITHM
   case 'asamin' 
        % initialize default asamin parameters
        asamin('reset');
	asamin('set','rand_seed',696969);
	asamin('set','test_in_cost_func',0);
	asamin('set','user_initial_parameters',1)
	asamin('set','delta_x',1e-3)
	asamin('set','temperature_ratio_scale',9e-1)

        % specific parameters
        for i = 1:length(FitPropertyName)
  	   asamin('set',FitPropertyName{i},FitPropertyValue{i})
        end

        assignin('base','fitparam',fitparam);
        xinit = xinit'; xu = xu'; xl = xl'; xt = xt';
	[fstar, xstar] = asamin('minimize','cost_function',xinit,xl,xu,xt);

   case 'fmincon'
        % initialize default fmincon parameters

        fmin_options = optimset('DiffMaxChange',1e-1,'DiffMinChange',1e-4,'LargeScale','off','TolFun',1e-6,'TolX',0.0);

        % specific parameters

        for i = 1:length(FitPropertyName)
           fmin_options = optimset(fmin_options,FitPropertyName{i},FitPropertyValue{i});
        end

        a = @cost_function;
	[xstar,fstar] = fmincon(a,xinit,[],[],[],[],xl,xu,[],fmin_options);
end



% generate best solution
%-----------------------

nX = 1;
for nC = 1:length(C)
   [C{nC},nX] = decode_syn_parameter(C{nC},xstar,nX,SynapsesToFit);

   % record from all liquid neurons
   C{nC}.OUTidx = -1; % ALL
end



