function O = apply(this,X)

if ~isempty(this.model)
  P = sum(([X ones(size(X,1),1)]*[this.model.W; this.model.B])>=0,2);
  O = min(1,max(-1,(P-this.n/2)/this.rho));
else
  warning('no model learned yet!');
end
