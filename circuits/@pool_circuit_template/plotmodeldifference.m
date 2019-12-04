function []=plotmodeldifference(this,model1,model2,O)
%PLOTMODELDIFFERENCE   plots the difference of the parameters of two pool template circuit model.
%   PLOTMODELDIFFERENCE(P,M1,M2,O) plots the difference of the parameters
%   of the two pool template circuit model M1 and M2. M1 and M2 could be different
%   models if their model parameters are of the same size. In case of a volterra
%   series exapansion O specifies the order of the kernel that is plotted.
%   In case of a cascade model O specifies the index of the subsystem in
%   the cascade.
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

if nargin < 4
   error('PLOTMODELDIFFERENCE needs four input arguments!')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

smc_class_name = class(this); % first argument must be from the POOL_CIRCUIT_TEMPLATE class

if (model1.data.ny > 1)||(model2.data.ny > 1)
   error('Only single output models allowed!')
end

k1 =  modelparameter(this,model1,O);
k2 =  modelparameter(this,model2,O);

if ~all(size(k1)==size(k2))
   error('The two specified models are incompatible!')
end

k= k1 - k2;
plotmodel(this,model1,O,k);


title_str = sprintf('Model: ''%s'' - ''%s''; kernel %i order',model1.info.type,model2.info.type,O);
title(title_str)


