function [this,mae,mse,cc,score]=train(this,stimuli,dataType,x_data,varargin)

if strcmp('precalcstates',lowerclean(dataType))
  ts.X = vertcat(x_data(:).X);

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
    verbose(0,'discretizeing states (eps=%g) ...',this.epsState);
    ts.X = round(ts.X/this.epsState);
    verbose(0,'\b\b\b\b. Done.\n');
  end
  
  verbose(0,'calculating target functions ...');
  f(length(stimuli)).y = [];
  for i=1:length(stimuli)
    f(i).y = target_values(this.targetFunction,stimuli(i),x_data(i).t);
  end
  verbose(0,'\b\b\b\b. Done.\n');

  ts.Y = vertcat(f(:).y);

  this.preprocess.P = [];
  if ~isempty(this.Vpca)
    if this.Vpca <=1 & this.Vpca >=0
      d = size(ts.X,2);
      verbose(0,'applying pca transformation ...');
      [ts.X,this.preprocess.P]=calc_pca(ts.X,this.Vpca);
      verbose(0,'\b\b\b\b. Keeping %i of %i dimensions.\n',size(ts.X,2),d);
    end
  end

  this.preprocess.meanx = [];
  this.preprocess.stdx  = [];
  if this.doNorm
    verbose(0,'applying mean/std transformation ...');
    [ts.X,this.preprocess.meanx,this.preprocess.stdx]=calc_stdnorm(ts.X);
    verbose(0,'\b\b\b\b. Done.\n');
  end

  if this.noise > 0
    verbose(0,'adding noise (%g) to training data ...',this.noise);
    maxabsX = mean(abs(ts.X(:)));
    ts.X = ts.X+gaussrnd(0,this.noise*maxabsX,size(ts.X,1),size(ts.X,2));
    verbose(0,'\b\b\b\b. Done.\n');
  end
  
  if this.nNoisyDuplicates > 0
    verbose(0,'adding noisy duplicates (%i) to training data ...',this.nNoisyDuplicates);
    ri=ceil(rand(this.nNoisyDuplicates,1)*size(ts.X,1));
    xd = ts.X(ri,:);
    xd = xd+gaussrnd(0,this.noise*maxabsX,size(xd,1),size(xd,2));
    ts.X = [ts.X; xd];
    ts.Y = [ts.Y; ts.Y(ri,:)];
    verbose(0,'\b\b\b\b. Done.\n');
  end

  this.preprocess.a = 1;
  this.preprocess.b = 0;
  range = get(this.algorithm,'range');
  if ~isempty(range)
    verbose(0,'scaling target values into range [%g %g] ...',range(1),range(2));
    ii=find(~isnan(ts.Y));
    b=min(ts.Y(ii));
    ts.Y = ts.Y-b;
    a=max(ts.Y(ii));
    if abs(a) < 1e-9
      error('all target values in the training set are equal (maxdiff=1e-9)!');
    end
    ts.Y = ts.Y/a*diff(range)+range(1);
    this.preprocess.a = a;
    this.preprocess.b = b;
    verbose(0,'\b\b\b\b. Done.\n');
  end
  
  if ~isempty(this.Kstratify)
    verbose(0,'stratifying data ...');
    i_pos=find(ts.Y>0);
    i_neg=find(ts.Y<=0);
    if this.Kstratify > 0
      if length(i_pos) < length(i_neg)
	i_kill = i_neg;
      elseif length(i_pos) > length(i_neg)
	i_kill = i_pos;
      else
	i_kill = [];
      end
      maxl=max(length(i_pos),length(i_neg));
      minl=min(length(i_pos),length(i_neg));
      nk = min(ceil(maxl-abs(this.Kstratify)*minl),length(i_kill));
      i_kill=i_kill(randperm(length(i_kill)));
      i_kill=i_kill(1:nk);
      ts.X(i_kill,:) = [];
      ts.Y(i_kill)   = [];
    elseif this.Kstratify == -1
      na=length(i_pos)-length(i_neg);
      if na > 0
	i_add = i_neg(ceil(rand(1,abs(na))*length(i_neg)));
      elseif na < 0
	i_add = i_pos(ceil(rand(1,abs(na))*length(i_pos)));
      else
	i_add = [];
      end
      if ~isempty(i_add)
	xd = ts.X(i_add,:);
	xd = xd+gaussrnd(0,this.noise*maxabsX,size(xd,1),size(xd,2));
	ts.X = [ts.X; xd];
	ts.Y = [ts.Y; ts.Y(i_add,:)];
      end
    end
    i_pos=find(ts.Y>0);
    i_neg=find(ts.Y<=0);
    if length(i_pos) > length(i_neg)
      verbose(0,'\b\b\b\b. #pos/#neg = %g\n',length(i_pos)/length(i_neg));
    else
      verbose(0,'\b\b\b\b. #neg/#pos = %g\n',length(i_neg)/length(i_pos));
    end
  end

  verbose(0,'training with %s (%i data points of dimension %i) ...',class(this.algorithm),length(ts.Y),size(ts.X,2));
  this.algorithm = train(this.algorithm,ts);
  verbose(0,'\b\b\b\b. Done.\n');
 
  [mae,mse,cc,score] = analyse(this.algorithm,ts);

  % verbose(0,'train performance: cc=%g, mae=%g, mse=%g, score=%g\n',cc,mae,mse,score);

elseif strcmp('samplestates',lowerclean(dataType))

  states = feval(x_data,stimuli,varargin{:});
  
  this = train(this,stimuli,'precalc_states',states);
end

