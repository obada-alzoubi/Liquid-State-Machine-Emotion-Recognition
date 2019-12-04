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

  vs.P = ValidSet.X;
  vs.T = ValidSet.Y;
else
  [TrainSet,ValidSet] = check_data(this,TrainSet,[],'transpose');
  
  vs = ValidSet;
end


minmax=repmat([min(TrainSet.X(:)) max(TrainSet.X(:))],[size(TrainSet.X,1) 1]);

this.net = newff(minmax, [this.nHidden 1], {'tansig' this.outActFun}, this.trainFun);
this.net = initnw(this.net,1);

this.net.trainParam.epochs   =       this.maxEpochs; % Maximum number of epochs to train
this.net.trainParam.show      =      ceil(this.maxEpochs/10); % Epochs between displays (NaN for no displays)
this.net.trainParam.goal       =       0; % Performance goal
this.net.trainParam.time        =    inf; % Maximum time to train in seconds
this.net.trainParam.min_grad    =   1e-6; % Minimum performance gradient
this.net.trainParam.max_fail    =     15; % Maximum validation failures
this.net.trainParam.lr          =    this.lr; % Learning rate

this.net.trainParam.mem_reduc   =    10; % Factor to use for memory/speed trade off


[this.net,tr,Y,E,Pf,Af] = train(this.net,TrainSet.X,TrainSet.Y,[],[],vs,[]);
