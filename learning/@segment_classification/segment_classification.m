function this = segment_classification(varargin)
%SEG_CLASS/SEG_CLASS  The constructor of the target function object
%  seg_class.
%
%  dr = seg_class(input_dist,p1,v1,p2,v2,...); creates a  'seg_class' object
%      for the input distribution input_dist (this is basically to check whether 
%      this target function can be calculated for this type of input distribution)
%      and with the specific values v1,v2, ... for the properties p1,p2,...
%      where valid properties are
%        'seg' ... the segment of which to report the class
%
%  Description: This target function object can (at the moment) only be used with
%      the 'jittered_templates' input distribution. In the following let TC be the
%      time when segment 'seg' starts ( TC = (seg-1)*Tmax/#segments ).
%      Then the target function y(t) is defined as follows: 
%
%      Case 1: 'multiClass' == 0
%
%         y(t) = 1,     if t >= TC and "local template of segment 'seg'" == 1
%         y(t) = 0,     if t >= TC and "local template of segment 'seg'" ~= 1
%         y(t) = undef, if t <  TC
%
%      Case 2: 'mulitClass' == 1
%
%         y(t) = "local template number", if t >= TC
%         y(t) = undef, if t <  TC
%
%  Example: Create an 'seg_class' object for a 'jittered_templates'
%      input distribution with three segments and a target function which
%      should return "the class" of segment two.
%
%      id = jittered_templates'(n',3);
%      dr = seg_class(id,'seg',2);
%
%  See also SEG_CLASS/TARGET_FUNCTION.
%
%  Author: Thomas Natschlaeger, 11/2001, tnatschl@igi.tu-graz.ac.at
%

this.description     = 'segment classification';

this.posSeg          = 1;
this.posSeg_comment  = 'number of segment to classifiy as positive';

this.multiClass          = 0;
this.multiClass_comment  = 'binary classification or mulit-class';

this.nValues         = 2;
this.nValues_comment = 'number of possible values of the target function (''Inf'' for real valued)';

this.public_properties = { 'posSeg' 'multiClass' };

[pathstr,name,ext,versn] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end
