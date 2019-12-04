function []=plot_response(this,varargin)
%PLOT_RESPONSE plot responses of pool circuit template.
%   PLOT_RESPONSE(PMC,R1,R2,...) plots the responses of the circuits
%   R1, R2, ... generated from the pool circuit template PMC.
%
%   See also POOL_CIRCUIT_TEMPLATES/GENERATE
%            POOL_CIRCUIT_TEMPLATES/PLOT
%	     POOL_CIRCUIT_TEMPLATES/POOL_CIRCUIT_TEMPLATES
%            POOL_CIRCUIT_TEMPLATES/ADJUST
%	     POOL_CIRCUIT_TEMPLATES/MODEL2STATES
%            POOL_CIRCUIT_TEMPLATES/STATES2MODEL
%	     POOL_CIRCUIT_TEMPLATES/VISUALIZE
%            POOL_CIRCUIT_TEMPLATES/SIMULATE
%
%   Author: Stefan Haeusler, 6/2003, haeusler@igi.tu-graz.ac.at

% convert input argument format to cell array

if nargin < 2
   error('Input argument pool circuit template responses ''R'' missing!');
end

for nR = 1:nargin-1
   R = varargin{nR};

   if ~isstruct(R)
      error('Response variable R must be of type ''struct''.')
   end

   % plot spike responses

   figure
   plot_response(R.R);
   name = get(R.C.template,'name');

   nA = length(get(gcf,'Children'));
   for nSB = 1:nA
      subplot(nA,1,nSB)
      title(sprintf('''%s'' response; Pool %i',name,nSB),'fontweight','bold')
      ylabel('neuron index')
      xlim([0 R.R{nSB}.Tsim])
   end
   
   % plot synaptic depression responses

   figure
   plot_depression(R);
end
