function display(obj)

% DISPLAY Display fields of the neural microcircuit object
%
%  Syntax
%
%    display(nmc)
%
%  Author
%
%    Christian Naeger, naeger@igi.tu-graz.ac.at


fn = fieldnames(obj);

maxl=0;
for j=1:length(fn)
  maxl=max(maxl,length(fn{j}));
end
maxl=maxl+2;

s=[];
for j=1:length(fn)
  if isempty(strfind(fn{j},'_comment')) & ~strcmp(fn{j},'public_properties')
    eval(sprintf('str=isstr(obj.%s);',fn{j}))
    eval(sprintf('num=isnumeric(obj.%s);',fn{j}))
    eval(sprintf('siz=size(obj.%s);',fn{j}))
    eval(sprintf('cl=class(obj.%s);',fn{j}))
    rw=':';
    if isempty(strmatch(fn{j},obj.public_properties,'exact'))
      rw='-';
    end
    if str
      estr=sprintf('s{j}=sprintf(''%s%s %s %%s'',obj.%s);\n',blanks(maxl-length(fn{j})),fn{j},rw,fn{j});
    elseif num & prod(siz) == 1
      estr=sprintf('s{j}=sprintf(''%s%s %s %%g'',obj.%s);\n',blanks(maxl-length(fn{j})),fn{j},rw,fn{j});
    else
      sizstr=sprintf('%i%s',siz(1),sprintf('x%i',siz(2:end)));
      estr=sprintf('s{j}=sprintf(''%s%s %s [ %s %s array ]'');\n',blanks(maxl-length(fn{j})),fn{j},rw,sizstr,cl);
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
fprintf('%sCLASS NAME - %s\n',blanks(maxl-10),upper(class(obj)));
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


