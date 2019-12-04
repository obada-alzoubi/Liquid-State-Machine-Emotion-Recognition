function this = combined(varargin)

this.description     = 'combine arbitary target functions';

this.targets          = {};
this.targets_comment  = 'cell array of target function to be combined';

this.expr             = '';
this.expr             = 'a string like ''f1*f2+sin(f3)'' which defines how to combine the target functions f1,f2,...';

this.public_properties = { 'targets' 'expr'  };


[pathstr,name,ext,versn] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end
