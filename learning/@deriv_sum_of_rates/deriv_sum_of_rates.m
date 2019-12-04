function this = deriv_sum_of_rates(varargin)

this.name            = 'deriv_sum_of_rates';
this.description     = 'at time t output the derivative of sum of rates of the time window [t-delay-W,t-delay]';
this.abbrev          = 'dr';
this.delay           = 0e-3;
this.delay_comment   = 'the delay of the time window [t-delay-W,t-delay]';
this.W               = 50e-3;
this.W_comment       = 'the width of the time window [t-delay-W,t-delay]';
this.fmax            = 100;
this.fmax_comment    = 'the maximal frequency assumed to occur';

this.target_type = 'regression';

if nargin == 0
  this = class(this,this.name);
elseif isa(varargin{1},this.name)
  this = varargin{1};
else
  this = class(this,this.name);
  this = set(this,varargin{:});
end

