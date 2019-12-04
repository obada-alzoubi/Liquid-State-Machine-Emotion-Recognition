function [mae,mse,cc,score] = analyse(this,set)

undef = find(isnan(set.Y));
set.X(undef,:) = [];
set.Y(undef)   = [];
  
%
% we scale Y into the range [0 1] and then we calculate the errors
% this simply amounts to scale the errors by the range of Y
%
if ~isempty(this.model)
  if prod(size(set.Y)) > 0
    scale=abs(diff(get(this,'range')));
    O     = apply(this,set.X);
    mae   = mean(abs(O-set.Y))/scale;
    mse   = mean((O-set.Y).^2)/(scale^2);
    cc    = corr_coef(O,set.Y);
    CM    = confusion_matrix(O,set.Y,[-1 1]);
    score = CM(1,2)/(1e-6+CM(1,1))+CM(2,1)/(1e-6+CM(2,2));
  else
    mae = NaN; mse=NaN; cc=NaN; score=NaN;
  end
end
