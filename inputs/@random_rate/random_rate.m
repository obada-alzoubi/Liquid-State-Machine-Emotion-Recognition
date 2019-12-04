function this = random_rate(varargin)

this.description     = 'genarates spike trains with a rate modulated by r(t) which is drawn randomly';

this.nChannels         = 4;
this.nChannels_comment = 'number of spiking channels';

this.Tstim             = -1; % if set to -1 we set Tstim to Tmax (in generate.m)
this.Tstim_comment     = 'length of stimulus (-1 ... specify the length in the call to generate)';

this.fmax              = 80;
this.fmax_comment      = 'maximal rate of a single channel';

this.binwidth          = 30e-3;
this.binwidth_comment  = 'in each interval of length binwidth a new random rate is drawn'; 

this.nRates            = Inf;
this.nRates_comment    = 'number of different rates that can be chosen (equal spaced in the interval [0,fmax]';

this.public_properties = { 'nChannels' 'Tstim' 'fmax' 'binwidth' 'nRates' };


[pathstr,name,ext,versn] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end
