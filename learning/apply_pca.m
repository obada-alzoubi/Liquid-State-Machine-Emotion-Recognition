function [Ptrans] = trapca(P,TransMat)
%TRAPCA Principal component transformation.
%	
%	Syntax
%
%	  [Ptrans] = trapca(P,TransMat)
%
%	Description
%	
%	  TRAPCA preprocesses the network input training set by applying 
%	  a principal component transformation that was previously computed 
%     by PREPCA.  This function needs to be used when a network has been 
%     trained using data normalized by PREPCA.  All subsequent inputs to 
%     the network need to be transformed using the same normalization.
%	
%	  TRAPCA(P,TransMat) takes these inputs,
%	    P        - RxQ matrix of centered input (column) vectors.
%       TransMat - Transformation matrix.
%	  and returns,
%       Ptrans   - Transformed data set.
%		
%	Examples
%
%	Algorithm
%
%	  Ptrans = TransMat*P;
%
%	See also PRESTD, PREMNMX, PREPCA, TRASTD, TRAMNMX.

if nargin ~= 2
  error('Wrong number of arguments.');
end


% Transform the data
Ptrans = P*TransMat;

