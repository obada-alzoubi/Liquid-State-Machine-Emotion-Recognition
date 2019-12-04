function this = pdelta(varargin)

this.name            = 'pdelta';
this.description     = 'parallel delta rule';
this.abbrev          = 'pdelta';
this.time            = -1;
this.time_comment    = 'time (in sec) needed to train the classifier';
this.range           = [-1 +1];
this.range_comment   = 'possible output range; e.g. [-1 +1].';


this.n                   = 21;
this.n_comment           = 'number of perceptrons';
this.rho                 = ceil(this.n*0.4);
this.rho_comment         = 'linear range of the squashing function';
this.eps                 = min(1,2/this.rho);
this.eps_comment         = 'target and output is considerd equal within +/- eps';
this.gamma               = 0.1;
this.gamma_comment       = 'initial margin';
this.maxwu               = 10;
this.maxwu_comment       = 'for adjustiing the margin gamma';
this.eta                 = NaN;
this.eta_comment         = 'initial learning rate; we set it to 1/#TBs';
this.mu                  = 1.2;
this.mu_comment          = 'extra learning rate';
this.max_err_inc         = 1.04;
this.max_err_inc_comment = 'max increase of error befor eta gets decr.';
this.lr_dec              = 0.7;
this.lr_dec_comment      = 'if error increses we set eta = eta*lr_dec';
this.lr_inc              = 1.05;
this.lr_inc_comment      = 'if error decreases we set eta = eta*lr_inc';
this.maxepoch            = 200;
this.maxepoch_comment    = 'maximum number of epochs';
this.model.W             = NaN;
this.model.B             = NaN;
this.model_comment       = 'contains the learned weight matrix W and biases B';
this.fig                 = NaN;
this.fig_comment         = 'figure to plot in';
this.valFrac             = 0;
this.valFrac_comment     = 'Fraction of data to use as validation set';
this.valid_wopt          = 0;
this.valid_wopt_comment  = '1: use weights where the min. err. on the valid set is achieved';
this.train_wopt          = 0;
this.train_wopt_comment  = '1: use weights where the min. err. on the train set is achieved';

[pathstr,name,ext,versn] = fileparts(mfilename);
if nargin == 0
  this = class(this,this.name);
elseif isa(varargin{1},this.name)
  this = varargin{1};
else
  this = class(this,this.name);
  this = set(this,varargin{:});
end
