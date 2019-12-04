function this = fisher_discriminant(varargin)

this.name              = 'fisher_discriminant';
this.description       = 'classification of the data projected into a low dim sub space';
this.abbrev            = 'fd';
this.time              = -1;
this.time_comment      = 'time (in sec) needed to train the classifier';
this.range             = [-1 +1];
this.range_comment     = 'possible label range; e.g. [-1 +1].';
this.model.J           = [];
% this.model_comment     = 'value of the criterion function';
this.model.W           = [];
% this.model_comment     = 'the calculated projection vectors';
this.model.C           = [];
% this.model_comment     = 'the calculated classification vectors';
this.model.B           = [];
% this.model_comment     = 'the calculated biaz for each classification vector';
this.model.class_label = [];
% this.model_comment     = 'label of each class';
this.model.error       = [];
% this.model_comment     = 'error of the eigenvalue equation due to matrix pseudo inversion';
this.model_comment     = 'contains projection and classification vectors, biaz and class labels';

if nargin == 0
  this = class(this,this.name);
elseif isa(varargin{1},this.name)
  this = varargin{1};
else
  this = class(this,this.name);
  this = set(this,varargin{:});
end
