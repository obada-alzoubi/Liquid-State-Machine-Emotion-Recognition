function r = exponentialrnd(mu,m,n);
%EXPRND Random matrices from exponential distribution.
%   R = EXPRND(MU) returns a matrix of random numbers chosen   
%   from the exponential distribution with parameter MU.
%   The size of R is the size of MU.
%   Alternatively, R = EXPRND(MU,M,N) returns an M by N matrix. 
 
%   EXPRND uses a simple inversion method. See Devroye, page 392.

%   References:
%      [1]  L. Devroye, "Non-Uniform Random Variate Generation", 
%      Springer-Verlag, 1986.

%     Copyright (c) 1993-98 by The MathWorks, Inc.
%     $Revision: 1.1.1.1 $  $Date: 2002/11/14 14:35:31 $


if nargin <  1, 
    error('Requires at least one input argument.'); 
end

rows = m;
columns = n;

%Initialize r to zero.
r = zeros(rows, columns);

u = rand(rows,columns);
r = - mu .* log(u);

% Return NaN if b is not positive.
if any(any(mu <= 0));
    tmp = NaN; 
    if prod(size(mu) == 1)
        r = tmp(ones(rows,columns));
    else
        k = find(mu <= 0);
        r(k) = tmp(ones(size(k)));
    end
end

