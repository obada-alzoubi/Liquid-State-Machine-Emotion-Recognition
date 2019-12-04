function y=apply(this,X)

y = [];

if ~isfield(this.preprocess,'P')
  if nargout == 0
    fprintf('this readout has not been trained yet!');
  end
  return
end

if ~isempty(this.preprocess.P)
  X = apply_pca(X,this.preprocess.P);
end

if ~isempty(this.preprocess.meanx)
  X = apply_stdnorm(X,this.preprocess.meanx,this.preprocess.stdx); 
end

y = apply(this.algorithm,X);

r = get(this.algorithm,'range');
if ~isempty(r)
  y = ((y-r(1))/diff(r))*this.preprocess.a+this.preprocess.b;
end
