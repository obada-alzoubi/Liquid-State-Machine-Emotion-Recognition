function O = apply(this,X)

O = (([X ones(size(X,1),1)]*this.model.W));
