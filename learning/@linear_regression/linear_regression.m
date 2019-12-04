function this = linear_regression(varargin)

this.name            = 'linear_regression';
this.description     = 'linear regression based on LMS';
this.abbrev          = 'linreg';
this.time            = -1;
this.time_comment    = 'time (in sec) needed to train the classifier';
this.range           = [-1 +1];
this.range_comment   = 'possible output range; e.g. [-Inf +Inf].';
this.model.W         = [];
this.model_comment   = 'model.W are the calculated regression coefficients';

if nargin == 0
  this = class(this,this.name);
elseif isa(varargin{1},this.name)
  this = varargin{1};
else
  this = class(this,this.name);
  this = set(this,varargin{:});
end
