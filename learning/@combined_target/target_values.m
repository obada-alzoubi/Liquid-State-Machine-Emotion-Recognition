function y=target_values(this,S,at_t)

if length(this.targets) > 0
  for i=1:length(this.targets)
    eval(sprintf('f%i=target_values(this.targets{i},S,at_t);',i));
  end  
  eval(sprintf('y=%s;',this.expr));
else
  y = NaN*ones(size(at_t));
end


