function this = train(this,TrainSet,varargin)

global PLOTTING_LEVEL

if this.valFrac > 0
  this.valFrac = min(this.valFrac,1);
  verbose(1,'splitting data into train (%g%%) and validation (%g%%) set ...',100*(1-this.valFrac),100*this.valFrac);
  vi = randperm(size(TrainSet.X,1));
  vi = vi(1:ceil(length(vi)*this.valFrac));
  ValidSet.X = TrainSet.X(vi,:);
  ValidSet.Y = TrainSet.Y(vi);
  TrainSet.Y(vi)   = [];
  TrainSet.X(vi,:) = [];  
  verbose(1,'\b\b\b\b. Done.\n');
  [TrainSet,ValidSet] = check_data(this,TrainSet,ValidSet,'transpose');
else
  [TrainSet,ValidSet] = check_data(this,TrainSet,[],'transpose');
end

t0=clock;
verbose(0,'training with %s (%i data points):\n',get(this,'name'),length(TrainSet.Y));

this.eta = 1/length(TrainSet.Y);

if PLOTTING_LEVEL > 0
  if isnan(this.fig), this.fig=gcf; end
  figure(this.fig); clf reset;
  %
  % call the learning procedure with plotting
  % and store the learned model
  %
  [this.model.W,this.model.B]=pdelta_batch(TrainSet,ValidSet,this,[],[],[],1);
else
  %
  % call the learning procedure without plotting
  % and store the learned model
  %
  [this.model.W,this.model.B]=pdelta_batch(TrainSet,ValidSet,this,[],100,[],0);
end  

this.time=etime(clock,t0);
