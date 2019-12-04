function this = jittered_templates(varargin)

%
%  Author: Thomas Natschlaeger, 11/2001, tnatschl@igi.tu-graz.ac.at
%

this.description     = 'jittered spike templates';


this.nChannels         = 1;
this.nChannels_comment = 'number of spike trains (channels)';

this.Tstim            = 0.5;
this.Tstim_comment    = 'length of spike trains';

this.jitter          = 4e-3;
this.jitter_comment  = 'jitter to add to each spike';

this.nTemplates      = [2];
this.nTemplates_comment     = 'number of templates per segment [1 x #Seg]';

this.templ_selection  = 'random';
this.templ_selection_comment = 'select templates ''sequential'' or ''random'' ';

this.freq            = [20];
this.freq_comment    = 'frequency of poisson spike train templates [1 x #Seg]';

this.nSpikes         = [];
this.nSpikes_comment = 'number of spikes per template (uniformly distributed) [1 x #Seg]';

this.segment         = struct([]);
this.segment_comment = 'stores the actual spike templates';

this.public_properties = { 'jitter' 'nChannels' 'Tstim' 'nTemplates' 'templ_selection' 'freq' 'nSpikes' 'segment'};

[pathstr,name,ext] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end

this=generate_templates(this);
