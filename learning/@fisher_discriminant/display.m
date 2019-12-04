function display(this)

fn = fieldnames(this);

maxl=0;
for j=1:length(fn)
  maxl=max(maxl,length(fn{j}));
end
maxl=maxl+2;

s=[];
for j=1:length(fn)
  if isempty(strfind(fn{j},'_comment'))
    eval(sprintf('str=isstr(this.%s);',fn{j}));
    eval(sprintf('stru=isstruct(this.%s);',fn{j}));
    eval(sprintf('num=isnumeric(this.%s);',fn{j}));
    eval(sprintf('siz=size(this.%s);',fn{j}));
    eval(sprintf('cl=class(this.%s);',fn{j}));
    if str
      estr=sprintf('s{j}=sprintf(''%s%s: %%s'',this.%s);\n',blanks(maxl-length(fn{j})),fn{j},fn{j});
    elseif stru
      sizstr=sprintf('%i%s',siz(1),sprintf('x%i',siz(2:end)));
      estr=sprintf('s{j}=sprintf(''%s%s: [ %s %s ]'');\n',blanks(maxl-length(fn{j})),fn{j},sizstr,cl);
    elseif num & prod(siz) == 1
      estr=sprintf('s{j}=sprintf(''%s%s: %%g'',this.%s);\n',blanks(maxl-length(fn{j})),fn{j},fn{j});
    else
      sizstr=sprintf('%i%s',siz(1),sprintf('x%i',siz(2:end)));
      estr=sprintf('s{j}=sprintf(''%s%s: [ %s %s array ]'');\n',blanks(maxl-length(fn{j})),fn{j},sizstr,cl);
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
%fprintf('%s  [ %s thisect ]\n',blanks(maxl),class(this));
for j=1:length(fn)
  if ~isempty(s{j})
    if ~isempty(strmatch(sprintf('%s_comment',fn{j}),fn,'exact'))
      eval(sprintf('com=this.%s_comment;',fn{j}));
      fprintf('%s%s%% %s \n',s{j},blanks(m-length(s{j})),com);
    else
      fprintf('%s\n',s{j});
    end
  end
end


