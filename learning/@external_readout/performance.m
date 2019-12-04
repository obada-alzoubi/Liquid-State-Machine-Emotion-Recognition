function [mae,mse,cc,score,CM,mi]=performance(this,stimuli,dataType,varargin)

if ~isfield(this.preprocess,'P')
  if nargout == 0
    fprintf('this readout has not been trained yet!');
  end
  [mae,mse,cc,score] = deal(NaN);
  return
end

if strcmp('precalcstates',lowerclean(dataType))
  ts.X = vertcat(varargin{1}(:).X);

  if ischar(this.subset)
    switch this.subset
     case 'all'
      subset = 1:size(ts.X,2);
     otherwise
      error('Unknown subset description!\b');
    end
  else
    subset = this.subset;
  end
  
  iKill = setdiff(1:size(ts.X,2),subset);
  ts.X(:,iKill) = [];

  if ( ~isempty(this.epsState) )
    ts.X = round(ts.X/this.epsState);
  end

  tmp(length(stimuli)).y = [];
  for i=1:length(stimuli)
    tmp(i).y = target_values(this.targetFunction,stimuli(i),varargin{1}(i).t);
  end
  ts.Y = vertcat(tmp(:).y);
  clear tmp


  if ~isempty(this.preprocess.P)
    ts.X = apply_pca(ts.X,this.preprocess.P);
  end
  
  if ~isempty(this.preprocess.meanx)
    ts.X = apply_stdnorm(ts.X,this.preprocess.meanx,this.preprocess.stdx); 
  end

  r = get(this.algorithm,'range');
  if ~isempty(r)
    ts.Y = (ts.Y-this.preprocess.b)/this.preprocess.a*diff(r)+r(1);
  end
  
  [mae,mse,cc,score] = analyse(this.algorithm,ts);

  if nargout == 0
    verbose(0,'performance: cc=%g, mae=%g, mse=%g, score=%g, mi=%h\n',cc,mae,mse,score,mi);
  end

elseif strcmp('samplestates',lowerclean(dataType))

  states = feval(varargin{1},stimuli,varargin{2:end});
  
  [mae,mse,cc,score,CM,mi]=performace(this,stimuli,'precalc_states',states);
  
end

