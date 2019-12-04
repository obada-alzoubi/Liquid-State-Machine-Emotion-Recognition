function [TrainSet,ValidSet] = check_data(this,TrainSet,ValidSet,tp,varargin)

if nargin < 3, ValidSet = []; end
if nargin < 4, tp = 'no'; end

if strncmp(upper(tp),'TRAN',4), tp = 1; else tp=0; end

i_def = find(~isnan(TrainSet.Y));
if ~isempty(i_def) 
  if length(i_def) < length(TrainSet.Y)
    TrainSet.X = TrainSet.X(i_def,:);
    TrainSet.Y = TrainSet.Y(i_def);
  end
  if tp 
    TrainSet.X = TrainSet.X';
    TrainSet.Y = TrainSet.Y';
  end
else
  TrainSet = [];
end
  
if ~isempty(ValidSet)
  i_def = find(~isnan(ValidSet.Y));
  if ~isempty(i_def)
    if length(i_def) < length(ValidSet.Y)
      ValidSet.X = ValidSet.X(i_def,:);
      ValidSet.Y = ValidSet.Y(i_def);
    end
    if tp 
      ValidSet.X = ValidSet.X';
      ValidSet.Y = ValidSet.Y';
    end
  else
    ValidSet = []; 
  end
end

if ~isempty(TrainSet)
  r = get(this,'range');
  if min(TrainSet.Y) < r(1), warning('target data out of range!'); end
  if max(TrainSet.Y) > r(2), warning('target data out of range!'); end
end
