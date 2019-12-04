function [modelOut]=states2model(this,STin,method,varargin)
%STATES2MODEL   estimates parameters of various models.
%   M = STATES2MODEL(P,ST,ME) estimates the model parameters M of
%   various model types ME to reproduce the input/output behavior of a
%   pool circuit template P specified in the circuit state variable ST.
%   (NOTE: The contents of P is irrelevant!)
%
%   The circuit state argument ST is an NS-by-NC cell array, where
%   NC is the number of pool circuit templates and NS is the number of
%   input stimuli, of structures with the fields
%
%	 'data'   ... matrix of size ND-by-NT, where ND is the circuit
%		      state space dimension (number of output neurons) and
%		      NT is the number of sampling time points
%	 'info'   ... contains informations about the creation of the
%		      ciruit states. It is a structure with the fields
%
% 		       'method'   ... a struct with fields
%
%		  		       'name'    ... transform. func. M
%				       'dt_bin'  ... sampling time steps
%
%                      'stimulus' ... stimulus, e.g. S1.
%                      'circuit'  ... a struct with field
%
%				       'template' ... e.g. C1.TEMPLATE
%
%   as returned by ST = RESPONSE2STATES(P,R).
%
%   ME specifies the model to be estimated:
%
%	 'impulse'       ... finite impulse response (acausal)
%	 'FIR'           ... finite impulse response
%	 'IIR'           ... infinite impulse resonse
%	 'wiener'        ... 2nd order wiener series
%	 'volterra'      ... 2nd order volterra series
%	 'volterra diag' ... undocumented :)
%	 'volterra fb'   ... 2nd order volterra series with 1st order feedback
%	 'LN'            ... linear dynamic/static nonlinear cascade
%	 'OS'            ... orthogonal search
%	 'FOS'           ... fast orthogonal search (general version)
%	 'FOS O(1)'      ... fast orthogonal search (faster than general vers.)
%	 'FOS O(2)'      ... fast orthogonal search (faster than general vers.)
%
%   The model output argument M is an NS-by-NC cell array of structures
%   with fields
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
%
%   See also POOL_CIRCUIT_TEMPLATE/GENERATE
%            POOL_CIRCUIT_TEMPLATE/PLOT
%	     POOL_CIRCUIT_TEMPLATE/POOL_CIRCUIT_TEMPLATE
%            POOL_CIRCUIT_TEMPLATE/ADJUST
%	     POOL_CIRCUIT_TEMPLATE/VISUALIZE
%            POOL_CIRCUIT_TEMPLATE/SIMULATE
%	     POOL_CIRCUIT_TEMPLATE/MODEL2STATES
%            POOL_CIRCUIT_TEMPLATE/RESPONSE2STATES
%
%   Author: Stefan Haeusler, 5/2003, haeusler@igi.tu-graz.ac.at

% convert input argument format to cell array

if iscell(STin)
   ST = STin;
else
   ST{1,1} = STin;
end

% check size

nCircuits = size(ST,2);
nStimuli = size(ST,1);


for nC = 1:nCircuits
   for nS = 1:nStimuli

      % interpolate input/output signals

      y = ST{nS,nC}.data;
      u = vertcat(ST{nS,nC}.info.stimulus.S.channel.data);

      dt_y = ST{nS,nC}.info.method.dt_bin;
      dt_u = ST{nS,nC}.info.stimulus.S.channel.dt;

      if dt_u < dt_y
         fprintf('Interpolate output signals from step size %g s to input signal step size %g s.\n',dt_y,dt_u)
         y_dt_u = interp1(cumsum(dt_y*ones(1,size(y,2)),2),y',cumsum(dt_u*ones(1,size(u,2)),2));
         y_dt_u(isnan(y_dt_u)) = 0;
         datorig = iddata2(y_dt_u,u',dt_u);
      elseif dt_u > dt_y
         fprintf('Interpolate input signals from step size %g s to output signal step size %g s.\n',dt_u,dt_y)
         u_dt_y = interp1(cumsum(dt_u*ones(1,size(u,2)),2),u',cumsum(dt_y*ones(1,size(y,2)),2));
         u_dt_y(isnan(u_dt_y)) = 0;
         datorig = iddata2(y',u_dt_y',dt_y);
      else
         datorig = iddata2(y',u',dt_y);
      end

      [dat,mu,stdu,my,stdy] = normalize_io(datorig);

      switch method

        case 'impulse'

	   model{nS,nC}.data = impulse(dat,'PW',0);
	   model{nS,nC}.info.type = method;
	   model{nS,nC}.info.stimulus = ST{nS,nC}.info.stimulus;
	   model{nS,nC}.info.circuit = ST{nS,nC}.info.circuit;

	case 'FIR'

	   nu = size(u,1);
	   ny = size(y,1);

	   orders = 40;

	   na = 0*eye(ny);
	   nb = orders*ones(ny,nu);
	   nk = 0*ones(ny,nu);  % causal

	   model{nS,nC}.data = arx(dat,[na nb nk]);
	   model{nS,nC}.info.type = method;
	   model{nS,nC}.info.stimulus = ST{nS,nC}.info.stimulus;
	   model{nS,nC}.info.circuit = ST{nS,nC}.info.circuit;

	case 'IIR'

	   nu = size(u,1);
	   ny = size(y,1);

	   orders = 40;

	   na = orders*eye(ny);
	   nb = orders*ones(ny,nu);
	   nk = 0*ones(ny,nu);  % causal

	   model{nS,nC}.data = arx(dat,[na nb nk]);
	   model{nS,nC}.info.type = method;
	   model{nS,nC}.info.stimulus = ST{nS,nC}.info.stimulus;
	   model{nS,nC}.info.circuit = ST{nS,nC}.info.circuit;

        case 'wiener'

           if (nargin > 3)
	      if ~isempty(varargin{1})
	         orders = varargin{1};
	      else
	         orders = 40;
	      end
	   else
	      orders = 40;
	   end

           [dat,mu,stdu,my,stdy] = normalize_io(datorig,orders);

	   model{nS,nC}.data = wiener_fit(dat,orders,varargin{2:end});
	   model{nS,nC}.info.type = method;
	   model{nS,nC}.info.stimulus = ST{nS,nC}.info.stimulus;
	   model{nS,nC}.info.circuit = ST{nS,nC}.info.circuit;

        case 'volterra'

           if (nargin > 3)
	      if ~isempty(varargin{1})
	         orders = varargin{1};
	      else
	         orders = 40;
	      end
	   else
	      orders = 40;
	   end

	   model{nS,nC}.data = volterra_fit(dat,orders,varargin{2:end});
	   model{nS,nC}.info.type = method;
	   model{nS,nC}.info.stimulus = ST{nS,nC}.info.stimulus;
	   model{nS,nC}.info.circuit = ST{nS,nC}.info.circuit;

        case 'volterra fb'

           if (nargin > 3)
	      if ~isempty(varargin{1})
	         orders = varargin{1};
	      else
	         orders = 40;
	      end
	   else
	      orders = 40;
	   end

	   model{nS,nC}.data = volterra_fb_fit(dat,orders,varargin{2:end});
	   model{nS,nC}.info.type = method;
	   model{nS,nC}.info.stimulus = ST{nS,nC}.info.stimulus;
	   model{nS,nC}.info.circuit = ST{nS,nC}.info.circuit;

        case 'volterra diag'

           if (nargin > 3)
	      if ~isempty(varargin{1})
	         orders = varargin{1};
	      else
	         orders = 40;
	      end
	   else
	      orders = 40;
	   end

	   if (nargin > 4)
	      if ~isempty(varargin{2})
	         nlinear = varargin{2};
	      else
	         nlinear = 10;
	      end
	   else
	      nlinear = 10;
	   end


	   model{nS,nC}.data = volterra_diag_fit(dat,orders,nlinear,varargin{3:end});
	   model{nS,nC}.info.type = method;
	   model{nS,nC}.info.stimulus = ST{nS,nC}.info.stimulus;
	   model{nS,nC}.info.circuit = ST{nS,nC}.info.circuit;

        case 'OS'

           if (nargin > 3)
	      if ~isempty(varargin{1})
	         orders = varargin{1};
	      else
	         orders = 40;
	      end
	   else
	      orders = 40;
	   end

	   if (nargin > 4)
	      if ~isempty(varargin{2})
	         nlinear = varargin{2};
	      else
	         nlinear = 2;
	      end
	   else
	      nlinear = 2;
	   end


	   model{nS,nC}.data = os_fit(dat,orders,nlinear,varargin{3:end});
	   model{nS,nC}.info.type = method;
	   model{nS,nC}.info.stimulus = ST{nS,nC}.info.stimulus;
	   model{nS,nC}.info.circuit = ST{nS,nC}.info.circuit;

        case 'FOS'

           if (nargin > 3)
	      if ~isempty(varargin{1})
	         orders = varargin{1};
	      else
	         orders = 40;
	      end
	   else
	      orders = 40;
	   end

	   if (nargin > 4)
	      if ~isempty(varargin{2})
	         nlinear = varargin{2};
	      else
	         nlinear = 2;
	      end
	   else
	      nlinear = 2;
	   end


	   model{nS,nC}.data = fos_fit(dat,orders,nlinear,varargin{3:end});
	   model{nS,nC}.info.type = method;
	   model{nS,nC}.info.stimulus = ST{nS,nC}.info.stimulus;
	   model{nS,nC}.info.circuit = ST{nS,nC}.info.circuit;

        case 'FOS O(1)'

           if (nargin > 3)
	      if ~isempty(varargin{1})
	         orders = varargin{1};
	      else
	         orders = 40;
	      end
	   else
	      orders = 40;
	   end

	   nlinear  = 1;

	   model{nS,nC}.data = vfos_fit(dat,orders,nlinear,varargin{3:end});
	   model{nS,nC}.info.type = method;
	   model{nS,nC}.info.stimulus = ST{nS,nC}.info.stimulus;
	   model{nS,nC}.info.circuit = ST{nS,nC}.info.circuit;

        case 'FOS O(2)'

           if (nargin > 3)
	      if ~isempty(varargin{1})
	         orders = varargin{1};
	      else
	         orders = 40;
	      end
	   else
	      orders = 40;
	   end

	   nlinear  = 2;

	   model{nS,nC}.data = vfos_fit(dat,orders,nlinear,varargin{3:end});
	   model{nS,nC}.info.type = method;
	   model{nS,nC}.info.stimulus = ST{nS,nC}.info.stimulus;
	   model{nS,nC}.info.circuit = ST{nS,nC}.info.circuit;

        case 'LN'

           if (nargin > 3)
	      if ~isempty(varargin{1})
	         orders = varargin{1};
	      else
	         orders = 40;
	      end
	   else
	      orders = 40;
	   end

           if (nargin > 4)
	      if ~isempty(varargin{2})
	         nlinear = varargin{2};
	      else
	         nlinear = 10;
	      end
	   else
	      nlinear = 10;
	   end

	   model{nS,nC}.data = LN_fit(dat,orders,nlinear,varargin{3:end});
	   model{nS,nC}.info.type = method;
	   model{nS,nC}.info.stimulus = ST{nS,nC}.info.stimulus;
	   model{nS,nC}.info.circuit = ST{nS,nC}.info.circuit;

        otherwise
	   err_str = sprintf('Response to state transformation ''%s'' unknown!',method)
	   error(err_str)
      end

      % store normalization parameters

      model{nS,nC}.data.mu = mu;
      model{nS,nC}.data.stdu = stdu;
      model{nS,nC}.data.my = my;
      model{nS,nC}.data.stdy = stdy;

   end
end

% convert to output argument format

if iscell(STin)
   modelOut = model;
else
   modelOut = model{1,1};
end


function [dat,mu,stdu,my,stdy] = normalize_io(dat,orders)

% normalize input/output data

if nargin < 2
   orders = 0;
end

[datau,mu,stdu] = prestd(dat.u');
[datay,my,stdy] = prestd(dat.y(orders+1:end,:)');

dat.u = datau';
dat.y(orders+1:end,:) = datay';

if orders > 0
   dat.y(1:orders,:) = trastd(dat.y(1:orders,:)',my,stdy)';
end



