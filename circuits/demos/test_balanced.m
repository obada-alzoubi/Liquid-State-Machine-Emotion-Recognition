clear all
close all
addpath ../..
lsm_startup

nInputChannels = 4;
DT = 30e-3;
InputDist = random_rate('binwidth',DT,'nChannels',nInputChannels,'nRates',Inf);
Tmax = 1.5;
lambda = Inf;

%
% balanced network
%
bmc =  balanced_fanin_circuit;
[bmc,p1] = add(bmc,'Pool','size',[5 20 5],'origin',[1 1 1]); % pool 1
bmc = add(bmc,'faninConn','dest',p1,'src',p1,'lambda',3);
bmc = balanceExcThresh(bmc,p1,{ @unirnd, 1/5, 1/7 } );
bmc = balanceInhExc(bmc,p1,{ @unirnd, 0.9, 1.1 } );
[bmc,pin] = add(bmc,'Pool','origin',[-1 2 1],'size',[1 1 nInputChannels ],'type','SpikingInputNeuron','frac_EXC',1);
bmc = add(bmc,'randConn','dest',p1,'src',pin,'Cscale',0.3,'type','StaticSpikingSynapse','rescale',0,'Wscale',0.15,'lambda',Inf);
bmc = record(bmc,'Pool',p1,'Field','spikes');


S=generate(InputDist,Tmax);
reset(bmc);
BR=simulate(bmc,Tmax+0.2,S);

figure(1); clf reset;
plot_pair(S,BR);

figure(2); clf reset;
plot(bmc);

pause

%
% normal network
%
nmc =  neural_microcircuit;
[nmc,p1] = add(nmc,'Pool','size',[3 3 15],'origin',[1 1 1]); % pool 1
nmc = add(nmc,'Conn','dest',p1,'src',p1,'lambda',lambda,'C(:)',0);
[nmc,pin] = add(nmc,'Pool','origin',[0 2 5],'size',[1 1 nInputChannels ],'type','SpikingInputNeuron','frac_EXC',1);
nmc = add(nmc,'Conn','dest',p1,'src',pin,'Cscale',2,'type','StaticSpikingSynapse','rescale',0,'Wscale',0.15,'lambda',Inf);
nmc = record(nmc,'Pool',p1,'Field','spikes');


% run the liquid on one input
reset(nmc);
NR=simulate(nmc,Tmax+0.2,S);

% plot the input in figure 1
figure(2); clf reset;
plot_pair(S,NR);
