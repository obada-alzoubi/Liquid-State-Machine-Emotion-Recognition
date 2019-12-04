function this =  combined_input(varargin)

this.description       = 'combination (concatenation) of arbitrary other inout distributions';

this.inputs            = {};
this.inputs_comment    = 'cell array of input distributions';

this.nChannels         = [];
this.nChannels_comment = 'overall number of channels';

this.public_properties = { 'inputs' };

[pathstr,name,ext,versn] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end

this.nChannels=0;
for i=1:length(this.inputs)
  this.nChannels  = this.nChannels + get(this.inputs{i},'nChannels');
end
