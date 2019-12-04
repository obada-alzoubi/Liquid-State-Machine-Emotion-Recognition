function params = export(this)

% EXPORT Exports a representation of the algorithm object
%
% Syntax
%
%    params = export(this)
%
% Arguments
%
%      params       ...   Double-vector represenation of the algorithm
%      this         ...   Algorithm object
%
% Description
%
% This function returns a double-vector representation of the
% algorithm object. This is used for importing algorithms into
% CSIM. 
%
% Author
%
%   Michael Pfeiffer, pfeiffer@igi.tugraz.at

if isfield(this.model, 'W')
  params = [size(this.model.W, 1)-this.addBias; this.addBias; this.nClasses; ...
	    this.model.W(:)];
else
  params = [];
end;  

  
