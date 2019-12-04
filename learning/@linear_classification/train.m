function this = train(this,TrainSet,varargin)
% LINEAR_CLASSIFICATION/TRAIN Train linear classifier(s)
%
% Syntax
%
%   LC = train(LC,trainSet);
%
% Arguments
%
%   trainSet.X - #samples x #dim matrix of train vectors
%   trainSet.Y - #samples x 1    vectro of train target values
%
% Description
%
%   LC = train(LC,trainSet); trains the linear classifier LC on tha
%   data given in trainSet and returns the trained classifier. The
%   resulting regression coefficients (weights) are stored in
%   LC.mode.W.
%
%   NOTE: There is no particular constraint on the target values
%   trainSet.Y except that there must be k=get(LC,'nClasses');
%   different values in trainSet.Y. If the is not met
%   train(LC,trainSet); stops with an error.
%  
% Example (train on random data)
%
%   data.X = rand(1000,11)-0.5;
%   data.Y = ceil(rand(1000,1)*4)*2-3; 
%   % data.Y: has [-1 1 3 5] as possible values
%
%   LC = linear_classification('nClasses',4);
%   LC = train(LC,data);
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


  t0=clock;

  nDim = size(TrainSet.X,2);
  i_def = find(~isnan(TrainSet.Y));
  if ~isempty(i_def) 
    if length(i_def) < length(TrainSet.Y)
      TrainSet.X = TrainSet.X(i_def,:);
      TrainSet.Y = TrainSet.Y(i_def);
    end
  else
    TrainSet = [];
  end
  
  if prod(size(TrainSet)) == 0
    % No data: return random weight vector
    this.model.W = rand(nDim+1,1)-0.5;
    return;
  end
  
  % There is some date
  
  % 1. Convert the target values into range 1:nClasses => indexedY
  this.model.uniqueY = [];
  [this.model.uniqueY,iDummy,indexedY]=unique(TrainSet.Y);
  
  if ( length(this.model.uniqueY) ~= this.nClasses )
    error(sprintf('Number of actual class values (%i) is different from this.nClasses = %i!\n',...
                  length(this.model.uniqueY),this.nClasses));
  end
    
  % 2. make -1/+1 vector representation
  n = length(indexedY);
  Y = sparse(1:n,indexedY,ones(n,1))*2-1;

  % 3. Find least squares solutions
  if this.addBias
    [Q, R]=qr([TrainSet.X ones(size(TrainSet.X,1),1)],0);
  else
    [Q, R]=qr(TrainSet.X,0);
  end

  if this.nClasses > 2
    % now we solve the nClasses > 2 regression problems
    this.model.W = zeros(nDim+1,1);
    for i=1:this.nClasses
      this.model.W(:,i) = R\(Q'*Y(:,i));
    end
  elseif this.nClasses == 2
    % now we solve the nClasses == 2 regression problems
    this.model.W = R\(Q'*Y(:,2));
  else
    error('nClasses == 1!?!?');
  end

  this.time=etime(clock,t0);
  
