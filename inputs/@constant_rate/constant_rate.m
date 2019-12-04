function this = constant_rate(varargin)

this.description       = 'genarates poisson spike trains with a constant rate r(t) = f';

this.nChannels         = 4;
this.nChannels_comment = 'number of spiking channels';

this.Tstim             = -1;
this.Tstim_comment     = 'length of stimulus (-1 ... specify the length in the call to generate)';

this.f                 = 20;
this.f_comment         = 'rates of each individual spiking channels';


this.public_properties = { 'nChannels' 'Tstim' 'f' };

[pathstr,name,ext,versn] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end
