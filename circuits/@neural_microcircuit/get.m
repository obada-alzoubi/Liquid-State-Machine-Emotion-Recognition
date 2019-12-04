function v = get(obj,prop,varargin)

if nargin < 2
  display(obj);
else

  fn = fieldnames(obj);
  
  i=strmatch(prop,fn,'exact');

  if ~isempty(i)
    eval(sprintf('v = obj.%s;',fn{i}));

    % extra options for struct arrays
    if isstruct(v) & (nargin > 2)
       v = getfield(v,varargin{:});
    end
 else
    errstr=sprintf('\nValid properties of %s:\n',upper(class(obj)));
    for j=1:length(fn)
      if isempty(strfind(fn{j},'_comment')) & isempty(strfind(fn{j},'_properties')) 
	errstr = [errstr sprintf('  %s\n',fn{j})];
      end
    end
    error(errstr);
  end
end
