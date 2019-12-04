function O = apply(this,X)

if ~isempty(this.model)
  O=sign(fwd(this.model,X));
else
  warning('no model learned yet!');
end
