function O = apply(this,X)

[idx,dummy] = find(compet( this.model.C'*X'- repmat(this.model.B',[1 size(X,1)]) ));
O = this.model.class_label(idx);

