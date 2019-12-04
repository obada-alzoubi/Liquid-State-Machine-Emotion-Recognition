function this = train(this,TrainSet,varargin)

global PLOTTING_LEVEL

[TrainSet,ValidSet] = check_data(this,TrainSet,[]);

t0=clock;
%verbose(0,'training with %s (%i data points) ...',get(this,'name'),length(TrainSet.Y));
net = train(svc, smosvctutor, TrainSet.X, TrainSet.Y, this.C, this.kernel);
net = fixduplicates(net, TrainSet.X, TrainSet.Y);
this.model = strip(net);
%verbose(0,'\b\b\b\b. Done (%d support vectors).\n', getnsv(this.model));

this.time=etime(clock,t0);
