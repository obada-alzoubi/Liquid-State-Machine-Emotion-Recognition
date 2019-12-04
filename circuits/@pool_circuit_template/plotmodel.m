function []=plotmodel(this,model,O,varargin)
%PLOTMODEL   plots the model parameters of a pool template circuit model.
%   PLOTMODEL(P,M,O) plots the parameters of a pool template
%   circuit model M. In case of a volterra series exapansion O specifies
%   the order of the kernel that is plotted. In case of a cascade model
%   O specifies the index of the subsystem in the cascade.
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
   error('PLOTMODEL needs three input arguments!')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

smc_class_name = class(this); % first argument must be from the POOL_CIRCUIT_TEMPLATE class


if model.data.ny > 1
   error('Only single output models allowed!')
end

 
% disp('ATTENTION: Wiener model selected')
% wiener_plot(model,O,varargin{:});
% break


switch model.info.type

   case 'wiener'

      wiener_plot(model,O,varargin{:});

   case 'volterra'

      volterra_plot(model,O,varargin{:});

   case 'volterra diag'

      volterra_diag_plot(model,O,varargin{:});

   case 'OS'

      os_plot(model,O,varargin{:});

   case 'FOS'

      fos_plot(model,O,varargin{:});

   otherwise
      err_str = sprintf('Model type ''%s'' not implemeneted!',model.info.type);
      error(err_str)
end



