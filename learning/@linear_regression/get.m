function v = get(this,prop)

fn = fieldnames(this);

i=strmatch(prop,fn,'exact');

if ~isempty(i)
  eval(sprintf('v = this.%s;',fn{i}));
else
  errstr=sprintf('\nValid properties of %s:\n',upper(class(this)));
  for j=1:length(fn)
    errstr = [errstr sprintf('  %s\n',fn{j})];
  end
  error(errstr);
end
