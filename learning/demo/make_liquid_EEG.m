%
% initialize a liquid
%
nmc = neural_microcircuit;

%
% create two default pools of CbNeuron
%
[nmc,p1] = add(nmc, 'Pool', 'type', 'CbNeuron', 'origin', [6 6 6],...
    'size', [7 7 7], 'frac_EXC', 0.8); % pool 1

%
% create one pool of analog input neurons
%
[nmc,pin] = add(nmc,'Pool','origin',[0 2 5],'size',[1 1 nInputChannels ],...
                'type','AnalogInputNeuron','frac_EXC',1);

%
% connect the input to the pools/pools
%
nmc = add(nmc,'Conn','dest',p1,'src',pin,'Cscale',0.2,'type','StaticAnalogSynapse',...
    'rescale',0,'Wscale',0.15,'lambda',Inf);
 
%
% add recurrent connections within the pools
%
nmc = add(nmc,'Conn','dest',p1,'src',p1,'lambda',2, 'type', 'DynamicStdpSynapse' );

%
% define the respones (i.e. what to record)
%
nmc = record(nmc,'Pool',p1,'Field','spikes');

