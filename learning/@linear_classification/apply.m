function O = apply(this,X)
% LINEAR_CLASSIFICATION/APPLY Apply train linear classifier(s) to data
%
% Syntax
%
%   O = apply(LC,X);
%
% Arguments
%
%   LC - the classifier
%    X - #samples x #dim matrix of test vectors
%
% Description
%
%   O = apply(LC,X); return the output of the classifier applied to
%   the test data X. Each row of X is one test vector.
%
% Example
% 
%   % make training data tr
%   tr.X=rand(1000,11)-0.5;
%   tr.Y=(sum(tr.X,2)>0);
% 
%   % do the training
%   LC = train(linear_classification,tr);
% 
%   % make test data te
%   te.X=rand(1000,11)-0.5;
%   te.Y=(sum(te.X,2)>0);
% 
%   % apply the trained classifier and measuer error
%   o = apply(LC,te.X);
%   err=mean( o ~= te.Y)
%
% See also
%
%   @linear_classification/train, @linear_classification/apply,
%   @linear_classification/analyse @linear_classification/set,
%   @linear_classification/get, @linear_regression/linear_regression
%
% Author
%
%   Thomas Natschlaeger, Dez. 2001 - Apr. 2003, tnatschl@igi.tu-graz.ac.at

  if this.addBias
    X = [X ones(size(X,1),1)];
  end
  if this.nClasses == 2
    maxI = ( X*this.model.W >= 0 ) + 1; % maxI \in {1,2}
  else
    % init memory for weighted sum
    S = zeros(size(X,1),this.nClasses);
    
    % apply each linear model to the data
    for i=1:this.nClasses
      S(:,i) = X*this.model.W(:,i);
    end
    
    % find model with maximum weighted sum S
    [maxV,maxI]=max(S,[],2);
      
  end
 
  % assign original values
  O = this.model.uniqueY(maxI);
