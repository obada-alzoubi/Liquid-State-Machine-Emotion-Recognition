function [xn] = apply_stdnorm(x,meanx,stdx)
%APPLY_STDNORM Preprocesses data using a precalculated mean and standard deviation.
%	
%	Syntax
%
%	  [xn] = apply_stdnorm(x,meanx,stdx)
%
%	Description
%	
%	APPLY_STDNORM preprocesses the network training set using 
%        the mean and 
%	  standard deviation that were previously computed by CALC_STDNORM.
%     This function needs to be used when a network has been trained 
%     using data normalized by CALC_STDNORM.  All subsequent inputs to the  
%     network need to be transformed using the same normalization.


if nargin ~= 3
  error('Wrong number of arguments.');
end
 
[m,d] = size(x);
one   = ones(m,1);
 
equal  = stdx==0;
nequal = ~equal;
if sum(equal) ~= 0
  stdx  = stdx.*nequal  + 1*equal;
end

xn = (x-one*meanx)./(one*stdx);
