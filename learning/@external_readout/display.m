function display(obj)

fn = fieldnames(obj);

maxl=0;
for j=1:length(fn)
  if isempty(strfind(fn{j},'_comment'))
    maxl=max(maxl,length(fn{j}));
  end
end
maxl=maxl+1;

s=[];
for j=1:length(fn)
  if isempty(strfind(fn{j},'_comment')) & ~strcmp(fn{j},'classifier')
    eval(sprintf('str=isstr(obj.%s);',fn{j}))
    eval(sprintf('num=isnumeric(obj.%s);',fn{j}))
    eval(sprintf('siz=size(obj.%s);',fn{j}))
    eval(sprintf('cl=class(obj.%s);',fn{j}))
    if str
      estr=sprintf('s{j}=sprintf(''%s%s: %%s'',obj.%s);\n',blanks(maxl-length(fn{j})),fn{j},fn{j});
    elseif num & prod(siz) == 0
      estr=sprintf('s{j}=sprintf(''%s%s: []'');\n',blanks(maxl-length(fn{j})),fn{j});
    elseif num & prod(siz) == 1
      estr=sprintf('s{j}=sprintf(''%s%s: %%g'',obj.%s);\n',blanks(maxl-length(fn{j})),fn{j},fn{j});
    elseif num & prod(siz) > 1
      sizstr=sprintf('%i%s',siz(1),sprintf('x%i',siz(2:end)));
      estr=sprintf('s{j}=sprintf(''%s%s: [ %s %s ]'');\n',blanks(maxl-length(fn{j})),fn{j},sizstr,cl);
    else
      sizstr=sprintf('%i%s',siz(1),sprintf('x%i',siz(2:end)));
      estr=sprintf('s{j}=sprintf(''%s%s: %s'');\n',blanks(maxl-length(fn{j})),fn{j},cl);
    end
    eval(estr);
  else
    s{j} = [];
  end
end

m=0;
for i=1:length(s)
  if isempty(strmatch(fn{i},{'name' 'description' 'abbrev'},'exact'))
    m=max(m,length(s{i}));
  end
end
m=m+2;

disp(' ');
%fprintf('%s  [ %s object ]\n',blanks(maxl),class(obj));
for j=1:length(fn)
  if ~isempty(s{j})
    if ~isempty(strmatch(sprintf('%s_comment',fn{j}),fn,'exact'))
      eval(sprintf('com=obj.%s_comment;',fn{j}));
      fprintf('%s%s%% %s \n',s{j},blanks(m-length(s{j})),com);
    else
      fprintf('%s\n',s{j});
    end
  end
end
fprintf('\n');


