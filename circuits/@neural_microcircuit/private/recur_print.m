function recur_print(this, p, b)

% RESET Recursivly print structures
%
%  Syntax
%
%    recur_print(this, p, b)
%
%  Description
%
%    Internal function: Currently only used for debugging purposes.


if isempty(p)
  fprintf('%s = []\n', b);
elseif isnumeric(p)
  [m,n] = size(p);
  if m==1 & n==1
    fprintf('%s = %g\n', b, double(p));
  else
    fprintf('%s = [%ix%i numeric]\n', b, m, n);
  end
  %if length(p(:)) > 10
  %fprintf('%s = [%ix%i double]\n', lb, size(p,1), size(p,2));
  %elseif length(p(:)) > 1
  %fprintf('%s = [ %g%s ]\n', lb, p(1), sprintf(' %g', double(p(2:end))));
  %else
  %fprintf('%s = %g\n', lb, double(p));
  %end
elseif isstruct(p)
  [m,n] = size(p);
  for i=1:m
    for j=1:n
      if m>1 & n > 1
	lb = sprintf('%s(%i,%i)', b, i, j);
      elseif m>1 | n>1
	lb = sprintf('%s(%i)', b, (i-1)*n+j);
      else
	lb = sprintf('%s', b);
      end

      fn = fieldnames(p);
      for f=1:length(fn)
	lb2 = sprintf('%s.%s', lb, fn{f});
	eval(sprintf('x=p(i,j).%s;', fn{f}));
	eval(sprintf('recur_print(this, x, ''%s'')', lb2));
      end
    end
  end
elseif iscell(p)
  [m,n] = size(p);
  for i=1:m
    for j=1:n
      if m>1 & n > 1
	lb = sprintf('%s{%i,%i}', b, i, j);
      elseif m>1 | n>1
	lb = sprintf('%s{%i}', b, (i-1)*n+j);
      else
	lb = sprintf('%s', b);
      end

      eval('x=p{i,j};');
      eval(sprintf('recur_print(this, x, ''%s'')', lb));
    end
  end
elseif ischar(p)
  fprintf('%s = %s\n', b, p);
else
  fprintf('Type not supported!\n');
end

