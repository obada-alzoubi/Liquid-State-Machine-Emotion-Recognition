function this = set(this,varargin)

fn = this.public_properties;

property_argin = varargin;
while length(property_argin) >= 2,
  prop = property_argin{1};
  val  = property_argin{2};
  property_argin = property_argin(3:end);
  i=strmatch(prop,fn,'exact');
  if ~isempty(i)

    % extra options for struct arrays
    if eval( sprintf('isstruct(this.%s)',fn{i}) ) & (nargin>3)
       eval(sprintf('v.%s=setfield(this.%s,varargin{2:end});',fn{i},fn{i}));
       % check that no new field will be created
       if eval(sprintf('length(fieldnames(v.%s))~=length(fieldnames(this.%s))',fn{i},fn{i}))
          errstr = sprintf(' Attempt to reference field of non-structure array ''%s''.',fn{i});
          error(errstr);
       end
       eval(sprintf('this.%s=v.%s;',fn{i},fn{i}));
       property_argin = []; % multi properties not possible if one property is a structure
    else
       eval(sprintf('this.%s = val;',fn{i}));
    end

  else
    errstr=sprintf('\n%s is not a public property.\nValid public properties of class %s:\n\n',prop,upper(class(this)));
    for j=1:length(fn)
      comment = eval(sprintf('this.%s_comment',fn{j}));
      errstr = [errstr sprintf('  %s : %s\n',fn{j},comment)];
    end
    error(errstr);
  end
end

if length(property_argin)
   error('Not enough input arguments.')
end
