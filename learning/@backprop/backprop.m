function this = pdelta(varargin)

this.description     = 'backpropagation';

this.time            = -1;
this.time_comment    = 'time (in sec) needed to train the classifier';

this.range           = [-0.9 +0.9];
this.range_comment   = 'possible output range; e.g. [-1 +1].';

this.valFrac   = 0.2;
this.valFrac_comment  = '';

this.outActFun = 'tansig';
this.outActFun_comment = 'activation function of output unit';

this.nHidden   = 5;
this.nHidden_comment   = 'number of hidden units';

this.trainFun  = 'trainlm';
this.trainFun_comment  = 'training procedure used (trainlm,traingdx,trainbfg)';

this.maxEpochs = 200;
this.maxEpochs_comment = 'maximum number of epochs';

this.lr = 0.1;
this.lr_comment = 'learning rate';

this.net = [];
this.net_comment = 'internally used structure';

this.public_properties = { 'valFrac' 'outActFun' 'nHidden' 'trainFun' 'maxEpochs' 'lr' };

[pathstr,name,ext,versn] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end
