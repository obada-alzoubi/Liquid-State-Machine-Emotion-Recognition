function this = spike_corr(varargin)

this.description      = 'correlation of spikes within the interval [t-delay-W,t-delay]';

this.delay            = 0e-3;
this.delay_comment    = 'the delay of the time window [t-delay-W,t-delay]';

this.W                = 50e-3;
this.W_comment        = 'the width of the time window [t-delay-W,t-delay]';

this.delta            = 5e-3;
this.delta_comment    = 'precision of coincidence detection';

this.channels         = [1 2];
this.channels_comment = 'input channels to look at';

this.public_properties = { 'delay' 'W' 'delta' 'channels' };

[pathstr,name,ext,versn] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end
