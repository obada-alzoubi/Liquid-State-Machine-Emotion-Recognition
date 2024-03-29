function ker = linear(arg)

% LINEAR
%
% Construct a linear kernel object,
%
%    K(x1, x2) = x1.x2';
%
% Examples:
%
%    % default constructor 
%
%    ker1 = linear;
%
%    % copy constructor
%
%    ker2 = linear(ker1);

%
% File        : @linear/linear.m
%
% Date        : Tuesday 12th September 2000
%
% Author      : Dr Gavin C. Cawley
%
% Description : Part of an object-oriented implementation of Vapnik's Support
%               Vector Machine, as described in [1].  
%
% References  : [1] V.N. Vapnik,
%                   "The Nature of Statistical Learning Theory",
%                   Springer-Verlag, New York, ISBN 0-387-94559-8,
%                   1995.
%
% History     : 07/07/2000 - v1.00
%               12/09/2000 - v1.01 minor improvements to comments and help
%                                  messages
%
% Copyright   : (c) Dr Gavin C. Cawley, September 2000 
%
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%

if nargin == 0
   
   % this is the default constructor

   ker.dummy = [];
   
   ker = class(ker, 'linear');
   
elseif isa(a, 'linear');
   
   % this is the copy constructor
   
   ker = a;
   
else

   % there are no other constructors
   
   help linear
   
end

% bye bye...

