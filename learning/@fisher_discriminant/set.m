function this = get(this,varargin)

fn = fieldnames(this);

property_argin = varargin;
while length(property_argin) >= 2,
  prop = property_argin{1};
  val  = property_argin{2};
  property_argin = property_argin(3:end);
  i=strmatch(prop,fn,'exact');
  if ~isempty(i)
    eval(sprintf('this.%s = val;',fn{i}));
  else
    errstr=sprintf('\nValid properties of %s:\n',upper(class(this)));
    for j=1:length(fn)
      errstr = [errstr sprintf('  %s\n',fn{j})];
    end
    error(errstr);
  end
end
