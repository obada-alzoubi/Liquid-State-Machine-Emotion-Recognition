function [data]=modelparameter(this,model,O,varargin)
%MODELPARAMETER   gets the model parameters of a pool template circuit model.
%   D = MODELPARAMETER(P,M,O) gets the parameters D of a pool template
%   circuit model M. In case of a volterra series exapansion O specifies
%   the order of the kernel. In case of a cascade model O specifies the 
%   index of the subsystem in the cascade.
%   (NOTE: The contents of P is irrelevant!)
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
%   Author: Stefan Haeusler, 8/2003, haeusler@igi.tu-graz.ac.at

if nargin < 3
   error('MODELPARAMETER needs three input arguments!')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

smc_class_name = class(this); % first argument must be from the POOL_CIRCUIT_TEMPLATE class


if model.data.ny > 1
   error('Only single output models allowed!')
end

if isfield(model.data,'h0')
   disp('only wiener model assumed')
   data = wiener_parameter(model,O,varargin{:});
elseif isfield(model.data,'a')
   disp('only FOS model assumed')
   data = fos_parameter(model,O,varargin{:});
end
break

switch model.info.type

   case 'wiener'

      data = wiener_parameter(model,O,varargin{:});

   case 'volterra'

      data = volterra_parameter(model,O,varargin{:});

   case 'volterra diag'

      data = volterra_diag_parameter(model,O,varargin{:});

   case 'OS'

      data = os_parameter(model,O,varargin{:});

   case 'FOS'

      data = fos_parameter(model,O,varargin{:});

   otherwise
      err_str = sprintf('Model type ''%s'' not implemeneted!',model.info.type);
      error(err_str)
end


