function this = fake_liquid(varargin)

this.description     = 'A fake liquid, i.e. a set of delay lines';

this.nInputs         = 1;
this.nInputs_comment = 'numer of inputs to the liquid';

this.nMulti          = 1;
this.nMulti_comment  = 'how often to duplicate the input channels';

this.delayRange           = [0 5e-3];
this.delayRange_comment   = 'range of delays to draw uniformly from';

this.jitter           = 0;
this.jitter_comment   = 'jitter to add after delay';

this.delays = [];
this.delays_comment = 'the actual delays';
 
[pathstr,name,ext,versn] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end

this.delayRange = sort(this.delayRange);
n=this.nInputs*this.nMulti;
this.delays = this.delayRange(1)+rand(1,n)*diff(this.delayRange);
