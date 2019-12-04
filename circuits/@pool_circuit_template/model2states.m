function [STout]=model2states(this,modelIn,varargin)
%MODEL2STATES   simulates various models.
%   ST = MODEL2STATES(P,M,S1,S2,...) simulates the models M with
%   input stimuli S1, S2 to generate the circuit states ST.
%   (NOTE: The contents of P is irrelevant!)
%
%   The model parameter M is a cell array of length NM, where NM is
%   the number of models of various types ME, of structures with fields
%
%	 'data'    ... model parameters
%	 'info'    ... info about the model and its parameter estimation
%
%	        	'type'     ... model type ME
%			'stimulus' ... stimulus used for param estimation
%                       'circuit'  ... a struct with field
%
%				       'template' ... pool circuit template
%						      that should be approx
%						      by the model
%
%   as returned by M = STATES2MODEL(P,ST,ME).
%
%   The circuit state parameter ST is an NS-by-NM cell array, where
%   NS is the number of input stimuli, of structures with fields
%
%	 'data'   ... matrix of size ND-by-NT, where ND is the circuit
%		      state space dimension (number of output neurons) and
%		      NT is the number of sampling time points
%	 'info'   ... contains informations about the creation of the
%		      ciruit states. It is a structure with the fields
%
% 		       'method'   ... a struct with fields
%
%		  		       'name'    ... model type ME
%				       'dt_bin'  ... sampling time steps
%
%                      'stimulus' ... stimulus, e.g. S1.
%                      'circuit'  ... a struct with field
%
%				       'template' ... pool circuit template
%						      that should be approx
%						      by the model
%
%   as returned by ST = RESPONSE2STATES(P,R).
%
%
%   See also POOL_CIRCUIT_TEMPLATE/GENERATE
%            POOL_CIRCUIT_TEMPLATE/PLOT
%	     POOL_CIRCUIT_TEMPLATE/POOL_CIRCUIT_TEMPLATE
%            POOL_CIRCUIT_TEMPLATE/ADJUST
%	     POOL_CIRCUIT_TEMPLATE/VISUALIZE
%            POOL_CIRCUIT_TEMPLATE/SIMULATE
%	     POOL_CIRCUIT_TEMPLATE/STATES2MODEL 
%            POOL_CIRCUIT_TEMPLATE/RESPONSE2STATES
%
%   Author: Stefan Haeusler, 5/2003, haeusler@igi.tu-graz.ac.at



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

smc_class_name = class(this); % first argument must be from the POOL_CIRCUIT_TEMPLATE class

for i = 1:(nargin-2)
   class_names{i} = class(varargin{i});
end

idx = strmatch('cell',class_names,'exact');
if ~isempty(idx)
   errstr = error(' Function ''model2states'' not defined for arguments of class ''cell''.');
end


% identify stimulus structures
%----------------------------------------------

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

% identify additional non struct varargin
%----------------------------------------------

vararginidx = setdiff(1:length(class_names),strmatch('struct',class_names,'exact'));

% check size

nStimuli = length(S);

if iscell(modelIn)
   model = modelIn;
else
   model{1} = modelIn;
end


for nM = 1:length(model)
   for nS = 1:nStimuli

      % interpolate input signals

      dt_u = S{nS}.channel.dt;
      dt_y = model{nM}.data.Ts;

      u = S{nS}.channel.data;
      if dt_u ~= dt_y
         fprintf('Interpolate input signals from step size %g s to model step size %g s.\n',dt_u,dt_y)

         u_dt_y = interp1(cumsum(dt_u*ones(1,size(u,2)),2),u',dt_y:dt_y:dt_u*length(u));
         u_dt_y(isnan(u_dt_y)) = 0;
      else
         u_dt_y = u;
      end

      % normalize input

      mu = model{nM}.data.mu;
      stdu = model{nM}.data.stdu;
      [u_dt_y] = trastd(u_dt_y,mu,stdu);

%      disp('ATTENTION: Model preselected!')
      if isempty(model{nM}.info)
         disp('ATTENTION: Model preselected!')
         model{nM}.info.type = 'wiener';
         model{nM}.info.nlinear = 2;
      end

      switch model{nM}.info.type

        case {'impulse'}

	    % fill up missing input channels
%	    nu = length(model{nM}.data.OutputUnit);
%	    u_dt_y(end+1:nu,:) = u_dt_y(end,:);

	    dat = iddata([],u_dt_y',dt_y);

	    y = sim(model{nM}.data,dat);

	    ST{nS,nM}.data = y.y';

            ST{nS,nM}.info.method.name = model{nM}.info.type;
            ST{nS,nM}.info.method.dt_bin = dt_y;

            ST{nS,nM}.info.stimulus.S = S{nS};
            ST{nS,nM}.info.circuit = model{nM}.info.circuit;

	    name = sprintf('%s (%s,%s)',model{nM}.info.type,get(ST{nS,nM}.info.circuit.template,'name'),...
	                                ST{nS,nM}.info.stimulus.S.info.name);
            ST{nS,nM}.info.circuit.template = set(ST{nS,nM}.info.circuit.template,'name',name);

        case {'FIR', 'IIR'}

	    dat = iddata([],u_dt_y',dt_y);

            y = sim(model{nM}.data,dat);

	    ST{nS,nM}.data = y.y';

            ST{nS,nM}.info.method.name = model{nM}.info.type;
            ST{nS,nM}.info.method.dt_bin = dt_y;

            ST{nS,nM}.info.stimulus.S = S{nS};
            ST{nS,nM}.info.circuit = model{nM}.info.circuit;

	    name = sprintf('%s (%s,%s)',model{nM}.info.type,get(ST{nS,nM}.info.circuit.template,'name'),...
	                                ST{nS,nM}.info.stimulus.S.info.name);
            ST{nS,nM}.info.circuit.template = set(ST{nS,nM}.info.circuit.template,'name',name);


        case 'wiener'

	    dat = iddata2([],u_dt_y',dt_y);

            y = wiener_sim(model{nM}.data,dat,varargin{vararginidx});

	    ST{nS,nM}.data = y';


           if (1)
            disp('ATTENTION: No info stored!')
           else
             
            ST{nS,nM}.info.method.name = model{nM}.info.type;
            ST{nS,nM}.info.method.dt_bin = dt_y;

            ST{nS,nM}.info.stimulus.S = S{nS};
            ST{nS,nM}.info.circuit = model{nM}.info.circuit;

	    name = sprintf('%s (%s,%s)',model{nM}.info.type,get(ST{nS,nM}.info.circuit.template,'name'),...
	                                ST{nS,nM}.info.stimulus.S.info.name);
            ST{nS,nM}.info.circuit.template = set(ST{nS,nM}.info.circuit.template,'name',name);
           end  

        case 'volterra'

	    dat = iddata2([],u_dt_y',dt_y);

            y = volterra_sim(model{nM}.data,dat);

	    ST{nS,nM}.data = y';

            ST{nS,nM}.info.method.name = model{nM}.info.type;
            ST{nS,nM}.info.method.dt_bin = dt_y;

            ST{nS,nM}.info.stimulus.S = S{nS};
            ST{nS,nM}.info.circuit = model{nM}.info.circuit;

	    name = sprintf('%s (%s,%s)',model{nM}.info.type,get(ST{nS,nM}.info.circuit.template,'name'),...
	                                ST{nS,nM}.info.stimulus.S.info.name);
            ST{nS,nM}.info.circuit.template = set(ST{nS,nM}.info.circuit.template,'name',name);


        case 'volterra fb'

	    dat = iddata2([],u_dt_y',dt_y);

            y = volterra_fb_sim(model{nM}.data,dat);

	    ST{nS,nM}.data = y';

            ST{nS,nM}.info.method.name = model{nM}.info.type;
            ST{nS,nM}.info.method.dt_bin = dt_y;

            ST{nS,nM}.info.stimulus.S = S{nS};
            ST{nS,nM}.info.circuit = model{nM}.info.circuit;

	    name = sprintf('%s (%s,%s)',model{nM}.info.type,get(ST{nS,nM}.info.circuit.template,'name'),...
	                                ST{nS,nM}.info.stimulus.S.info.name);
            ST{nS,nM}.info.circuit.template = set(ST{nS,nM}.info.circuit.template,'name',name);

        case 'volterra diag'

	    dat = iddata2([],u_dt_y',dt_y);

            y = volterra_diag_sim(model{nM}.data,dat);

	    ST{nS,nM}.data = y';

            ST{nS,nM}.info.method.name = model{nM}.info.type;
            ST{nS,nM}.info.method.dt_bin = dt_y;

            ST{nS,nM}.info.stimulus.S = S{nS};
            ST{nS,nM}.info.circuit = model{nM}.info.circuit;

	    name = sprintf('%s (%s,%s)',model{nM}.info.type,get(ST{nS,nM}.info.circuit.template,'name'),...
	                                ST{nS,nM}.info.stimulus.S.info.name);
            ST{nS,nM}.info.circuit.template = set(ST{nS,nM}.info.circuit.template,'name',name);


        case 'LN'

	    dat = iddata2([],u_dt_y',dt_y);

            y = LN_sim(model{nM}.data,dat);

	    ST{nS,nM}.data = y';

            ST{nS,nM}.info.method.name = model{nM}.info.type;
            ST{nS,nM}.info.method.dt_bin = dt_y;

            ST{nS,nM}.info.stimulus.S = S{nS};
            ST{nS,nM}.info.circuit = model{nM}.info.circuit;

	    name = sprintf('%s (%s,%s)',model{nM}.info.type,get(ST{nS,nM}.info.circuit.template,'name'),...
	                                ST{nS,nM}.info.stimulus.S.info.name);
            ST{nS,nM}.info.circuit.template = set(ST{nS,nM}.info.circuit.template,'name',name);


        case 'OS'

	    dat = iddata2([],u_dt_y',dt_y);

            y = os_sim(model{nM}.data,dat);

	    ST{nS,nM}.data = y';

            ST{nS,nM}.info.method.name = model{nM}.info.type;
            ST{nS,nM}.info.method.dt_bin = dt_y;

            ST{nS,nM}.info.stimulus.S = S{nS};
            ST{nS,nM}.info.circuit = model{nM}.info.circuit;

	    name = sprintf('%s (%s,%s)',model{nM}.info.type,get(ST{nS,nM}.info.circuit.template,'name'),...
	                                ST{nS,nM}.info.stimulus.S.info.name);
            ST{nS,nM}.info.circuit.template = set(ST{nS,nM}.info.circuit.template,'name',name);


        case 'FOS'

	    dat = iddata2([],u_dt_y',dt_y);

            y = fos_sim(model{nM}.data,dat);

	    ST{nS,nM}.data = y';

            ST{nS,nM}.info.method.name = model{nM}.info.type;
            ST{nS,nM}.info.method.dt_bin = dt_y;

            ST{nS,nM}.info.stimulus.S = S{nS};
            ST{nS,nM}.info.circuit = model{nM}.info.circuit;

           if (1)
            disp('ATTENTION: No info stored!')
           else
             
	    name = sprintf('%s (%s,%s)',model{nM}.info.type,get(ST{nS,nM}.info.circuit.template,'name'),...
	                                ST{nS,nM}.info.stimulus.S.info.name);
            ST{nS,nM}.info.circuit.template = set(ST{nS,nM}.info.circuit.template,'name',name);
           end  


        otherwise
	   err_str = sprintf('Model type ''%s'' unknown!',model.info,type)
	   error(err_str)
     end
     
     % rescale output

     my = model{nM}.data.my;
     stdy = model{nM}.data.stdy;
     ST{nS,nM}.data = poststd(ST{nS,nM}.data,my,stdy);

   end
end

% convert to output

STout = ST;



