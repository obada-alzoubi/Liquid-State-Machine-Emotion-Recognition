function this = train(this,TrainSet,varargin)

[TrainSet,ValidSet] = check_data(this,TrainSet,varargin);

%
% call the learning procedure
% and store the learned model
%
if size(TrainSet.X,1) < size(TrainSet.X,2)+1
  error('Not enough data to calculate a linear regression!');
end
%verbose(0,'training with %s (%i data points) ...',get(this,'name'),length(TrainSet.Y));
t0=clock;
this.model.W = regress(TrainSet.Y,[TrainSet.X ones(size(TrainSet.X,1),1)]);
%verbose(0,'\b\b\b\b. Done.\n');
this.time=etime(clock,t0);
