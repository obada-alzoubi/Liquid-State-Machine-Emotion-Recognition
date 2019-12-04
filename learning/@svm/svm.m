function this = pdelta(varargin)

this.name            = 'svm';
this.description     = 'support vector machine';
this.abbrev          = 'svm';
this.time            = -1;
this.time_comment    = 'time (in sec) needed to train the classifier';
this.range           = [-1 +1];
this.range_comment   = 'possible output range; e.g. [-1 +1].';


this.C                   = 10;
this.C_comment           = 'the C parameter of a SVM';
this.kernel              = linear;
this.kernel_comment      = 'kernel of the SVM';
this.model               = [];
this.model_comment       = 'the learned SVM model';

if nargin == 0
  this = class(this,this.name);
elseif isa(varargin{1},this.name)
  this = varargin{1};
else
  this = class(this,this.name);
  this = set(this,varargin{:});
end
