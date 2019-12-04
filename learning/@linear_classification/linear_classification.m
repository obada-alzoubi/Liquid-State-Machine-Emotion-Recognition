function this = linear_classification(varargin)
% LINEAR_CLASSIFICATION Linear classification based on LMS
%
% Syntax
%
%   lc =  LINEAR_CLASSIFICATION(property,value,property,value,...);
%
% Description
%
%   LINEAR_CLASSIFICATION is the constructor of the object
%   @LINEAR_CLASSIFICATION.
%  
%   lc = LINEAR_CLASSIFICATION(property,value,property,value,...);
%   instantiates an object where the given properties (passed as
%   strings) are initialized to the corresponding values.
%
%   This classifier as able to deal not only with binary
%   classification problems but also with k-class classification
%   problems. k is specified by the property 'nClasses' (see below).
%  
% Valid properties of LINEAR_CLASSIFICATION objects
%
%     nClasses - number of classes of the target values (default: 2)
%     range    - possible output range of the classifier: NOT USED ANYMORE
%
% Available methods
%
%     train   - train on given data
%     apply   - apply train classifier to (test) data
%     analyse - analyse the performance of train classifier on (test)
%               data
%     set     - set (public) properties
%     get     - get (any) properties
%
% See also
%
%   @linear_classification/train, @linear_classification/apply,
%   @linear_classification/analyse @linear_classification/set,
%   @linear_classification/get, @linear_regression/linear_regression
%
% Author
%
%   Thomas Natschlaeger, Dez. 2001 - Apr. 2003, tnatschl@igi.tu-graz.ac.at
   
this.name            = 'linear_classification';
this.description     = 'linear classification based on LMS';

this.nClasses         = 2;
this.nClasses_comment = 'number of classes of the target values';

this.addBias          = 1;
this.addBias_comment  = 'flag: 1 ... add bias (w0) to model; 0 ... do not add bias';

this.time            = -1;
this.time_comment    = 'time (in sec) needed to train the classifier';

this.range           = [];
this.range_comment   = 'NOT USED ANYMORE!';

this.model           = [];
this.model_comment   = 'holds the calculated regression coefficients';

this.public_properties = { 'name' 'nClasses' 'range' 'addBias' };

if nargin == 0
  this = class(this,this.name);
elseif isa(varargin{1},this.name)
  this = varargin{1};
else
  this = class(this,this.name);
  this = set(this,varargin{:});
end
