function this = external_readout(varargin)

this.name         = 'external_readout';
this.abbrev       = 'extreadout';
this.description  = 'Object for training an external readout';

this.targetFunction           = [];
this.targetFunction_comment   = 'The target function y(t) for which to train.';

this.algorithm                = linear_regression;
this.algorithm_comment        = 'The supervised training algorithm to use.'; 

this.Vpca                     = [];
this.Vpca_comment             = 'The fraction of variance to hold in the data after a PCA.';

this.Kstratify                = [];
this.Kstratify_comment        = 'The #pos/#neg ratio of the stratified data.';

this.doNorm                   = 1;
this.doNorm_comment           = 'Flag: 1 ... mean/std normalization, 0 ... no normalization';

this.noise                    = 0.01;
this.noise_comment            = 'Amount of noise added to the data before training';

this.epsState                 = [];
this.epsState_comment         = 'if nonempty epsState is used to discretize the states: Xd = round(X/epsState)';

this.nNoisyDuplicates         = 0;
this.nNoisyDuplicates_comment = 'Numer of noisy duplicates of training examples to add';

this.subset                   = 'all';
this.subset_comment           = 'indices of dimension to use for the readout';

% this.testProcedure            = 'random split';
% this.testProcedure_comment    = 'random split / separate test set / cross-validation';
% 
% this.k                        = 10;
% this.k_comment                = 'number of folds for crossvalidation';
% 
% this.trainFraction            = 0.6;
% this.trainFraction_comment    = 'fraction of availabe data to use for training';

this.preprocess                 = [];

if nargin == 0
  this = class(this,this.name);
elseif isa(varargin{1},this.name)
  this = varargin{1};
else
  this = class(this,this.name);
  this = set(this,varargin{:});
end
