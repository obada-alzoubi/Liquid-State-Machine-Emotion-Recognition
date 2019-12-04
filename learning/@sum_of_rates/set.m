function this = set(this,varargin)

if rem(length(varargin),2)
  error('Wrong number of arguments.');
end

fn = this.public_properties;

property_argin = varargin;
while length(property_argin) >= 2,
  prop = property_argin{1};
  val  = property_argin{2};
  property_argin = property_argin(3:end);
  i=strmatch(prop,fn,'exact');
  if ~isempty(i)
    eval(sprintf('this.%s = val;',fn{i}));
  else
    errstr=sprintf('\n%s is not a public property.\nValid public properties of class %s:\n\n',prop,upper(class(this)));
    fn
    for j=1:length(fn)
      comment = eval(sprintf('this.%s_comment',fn{j}));
      errstr = [errstr sprintf('  %s : %s\n',fn{j},comment)];
    end
    error(errstr);
  end
end
