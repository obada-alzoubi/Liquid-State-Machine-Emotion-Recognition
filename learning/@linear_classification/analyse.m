function [mae,mse,cc,score,CM,mi,hx,hy] = analyse(this,set)
% LINEAR_CLASSIFICATION/APPLY Analyse a trained linear classifier(s) on data
%
% Syntax
%
%   [err,mse,cc,score,CM,mi] = apply(LC,testSet);
%
% Arguments
%
%   LC - the classifier
%   trainSet.X - #samples x #dim matrix of test vectors
%   trainSet.Y - #samples x 1    vectro of test target values
%
% Return values
%
%   err   - classification error
%   mse   - mean squared error (not very meaningful)
%    cc   - correlation coefficient bewteen target and classifier output
%   score - error measurement which takes into account the confusion matrix  
%   CM    - the confusion matrix: CM(i,j) is the number of examples
%           classified as class i while beeing actually class j.
%   mi    - mutual information between 
%           target and classifier output (calculated from CM).
%   hx    - entropy of target values
%   hy    - entropy of classifier output
%
% Description
%
%   O = analyse(LC,testSet); applies the classifier LC to the data
%   testSet.X and returns the above listed error/performance measures
%   between the classifier output and testSet.Y.
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
%   [err,mse,cc,score,CM,mi] = analyse(LC,te)
%
% See also
%
%   @linear_classification/train, @linear_classification/apply,
%   @linear_classification/analyse @linear_classification/set,
%   @linear_classification/get, @linear_regression/linear_regression,
%   confusion_matrix
%
% Author
%
%   Thomas Natschlaeger, Dez. 2001 - Apr. 2003, tnatschl@igi.tu-graz.ac.at

undef = find(isnan(double(set.Y)));
set.X(undef,:) = [];
set.Y(undef)   = [];
  
if ~isempty(this.model)
  if prod(size(set.Y)) > 0
    % apply the classifier
    O     = apply(this,set.X);
    
    % mean classification error
    mae   = mean(O~=double(set.Y));
    
    % mean squared error: not very meaningful here
    mse   = mean((O-double(set.Y)).^2);
    
    % correlatio coefficient
    cc    = corr_coef(O,double(set.Y));
    
    % confusion matrx
    CM    = confusion_matrix(O,double(set.Y),this.model.uniqueY);
    
    % error score: takes into account false and positive negatives
    score = CM(1,2)/(1+CM(1,1))+CM(2,1)/(1+CM(2,2));
    
    % calculate mutual information and entropies between target and classifier output
    [mi,hx,hy]    = mi_from_count(CM); 
    
  else
    mae = NaN; mse=NaN; cc=NaN; score=NaN; CM=[]; mi=NaN;
  end
end
