function this = sum_of_rates(varargin)

this.description     = 'sum of rates in the time window [t-delay-W,t-delay]';

this.delay           = 0e-3;
this.delay_comment   = 'the delay of the time window [t-delay-W,t-delay]';

this.W               = 50e-3;
this.W_comment       = 'the width of the time window [t-delay-W,t-delay]';

this.fmax            = 100;
this.fmax_comment    = 'the maximal frequency assumed to occur';

this.nValues         = Inf;
this.nValues_comment = 'number of possible values of the target function (''Inf'' for real valued)';

this.channels         = [];
this.channels_comment = 'over which channels do calculate the sum of rates';

this.public_properties = { 'delay' 'W' 'fmax' 'channels' };


[pathstr,name,ext,versn] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end

this.description = sprintf('sum of rates in the window [t-%gms,t-%gms]',1000*(this.delay+this.W),1000*(this.delay));
