function v = get(obj,prop)

fn = fieldnames(obj);

i=strmatch(prop,fn,'exact');

if ~isempty(i)
  eval(sprintf('v = obj.%s;',fn{i}));
else
  errstr=sprintf('\nValid properties of %s:\n',upper(class(obj)));
  for j=1:length(fn)
    errstr = [errstr sprintf('  %s\n',fn{j})];
  end
  error(errstr);
end
