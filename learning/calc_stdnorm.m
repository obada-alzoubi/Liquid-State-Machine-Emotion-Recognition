function [xn,meanx,stdx] = calc_stdnorm(x)
%CALC_STDNORM Preprocesses the data so that the mean is 0 and the standard deviation is 1.
%	
%	Syntax
%
%	  [px,meanx,stdx] = calc_stdnorm(x)
%
%	Description
%	
%	  CALC_STDNORM preprocesses the network training
%	  set by normalizing the inputs and targets so that
%         they have means of zero and standard deviations of 1.
%
%	Algorithm
%
%         xn = (x-meanx)/stdx;


if nargin > 2
  error('Wrong number of arguments.');
end

meanx = mean(x,1);
stdx  = std(x,0,1);
[m,d] = size(x);
one   = ones(m,1);

equal  = stdx==0;
nequal = ~equal;
if sum(equal) ~= 0
  stdx  = stdx.*nequal  + 1*equal;
end

xn = (x-one*meanx)./(one*stdx);
