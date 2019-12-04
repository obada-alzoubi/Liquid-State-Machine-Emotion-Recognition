
% Initial (Matlab related) stuff

startup;

VERBOSE_LEVEL = 2; % the higher the more is printed at stdout
PLOTTING_LEVEL = 1; % the gigher the more plots will appear

% decide wether to use a fake liquid (i.e. set of delay lines) or a
% real one
FAKE = 0; 


% define the input distribution
Tmax = 0.5;
nInputChannels=1;
InputDist = jittered_templates('nChannels',nInputChannels,'nTemplates',[2],'Tstim',Tmax,'jitter',4e-3);

% define the neural circuit (liquid
if FAKE
  fprintf('***\n*** FAKE LIQUID\n***\n');
  nmc=delay_lines('nMulti',135,'delayRange',[0 20e-3],'nInputs',nInputChannels);
else
  make_liquid
end

% do some plotting if required
if PLOTTING_LEVEL > 0
  % run the liquid on one input
  S=generate(InputDist);
  reset(nmc);
  R=simulate(nmc,Tmax,S);

  % plot the input in figure 1
  figure(1); clf reset;
  plot(InputDist,S);

  % plot the response in figure 2
  figure(2); clf reset;
  plot_response(R);

  % and wait for any key
  anykey;
end


% collect stimulus/response pairs for training
[train_response,train_stimuli] = collect_sr_data(nmc,InputDist,500);

% we train all the readouts on the same set of states so we
% precalculate them
train_states  = response2states(train_response,[],[0:0.025:Tmax]); 




% and now some test data
[test_response,test_stimuli] = collect_sr_data(nmc,InputDist,200);

test_states = response2states(test_response,[],[0:0.025:Tmax]);


% train readout with different learning algorithms
clear readout

readout{1} = external_readout(...
    'description','with linear classification',...
    'targetFunction',segment_classification,...
    'algorithm',linear_classification);

readout{2} = external_readout(...
    'description','with pdelta',...
    'targetFunction',segment_classification,...
    'algorithm',pdelta('n',51,'rho',20,'maxepoch',150,'valid_wopt',1,'valFrac',0.2));
 
readout{3} = external_readout('description','with linear regression',...
 'targetFunction',segment_classification,...
 'algorithm',linear_regression);
 
readout{4} = external_readout(...
    'description','with backpropagation',...
    'targetFunction',segment_classification,...
    'algorithm',backprop);
 

[trained_readouts, perf_train, perf_test] = train_readouts(readout,train_states,train_stimuli,test_states,test_stimuli);

% now we plot the result AT OTHER SAMPLING TIME POINTS
VERBOSE_LEVEL  = 0;
plot_readouts(trained_readouts,test_response,test_stimuli,{ 'response2states' '[0:0.02:Tmax]' });
