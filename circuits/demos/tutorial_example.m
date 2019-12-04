clear all
close all
addpath ../..
lsm_startup

nmc = neural_microcircuit;

[nmc, p_lif ] = add(nmc,'pool','type','LifNeuron','size',[3 3 6],'origin',[2 1 1]);

figure(1); clf reset;
%plot(nmc);
%print -djpeg -r0 p_lif.jpg
%print -dpng -r0 p_lif.png
%print -depsc2 p_lif.eps

[nmc,p_sig]=add(nmc,'pool','type','SigmoidalNeuron',...
                       'size',[3 3 6],'origin',[6 1 1],...
                       'Neuron.thresh',1,'Neuron.beta',2,'Neuron.tau_m',3,...
                       'Neuron.A_max',4,'Neuron.I_inject',1,'Neuron.Vm_init',0);


[nmc,p_hh ]=add(nmc,'pool','type','HHNeuron',...
                       'size',[3 3 6],'origin',[10 1 1],...
                       'Neuron.Inoise',0,'Neuron.Iinject',[0 0]);

figure(1); clf reset;
%plot(nmc);
%print -djpeg -r0 p123.jpg
%print -dpng -r0 p123.png
%print -depsc2 p123.eps

[nmc,p_sin] = add(nmc,'pool','type','SpikingInputNeuron',...                  
                  'size',[1 1 2],'origin',[0 1 5],'frac_EXC',1.0);

[nmc,p_ain] = add(nmc,'pool','type','AnalogInputNeuron',...                  
                  'size',[1 1 1],'origin',[0 1 2]);


figure(1); clf reset;
%plot(nmc);
%print -djpeg -r0 p123.jpg
%print -dpng -r0 p123.png
%print -depsc2 p123.eps

[nmc,c(1)]=add(nmc,'conn','dest',[6 1 1; 6 3 6],'src',p_sin,...
               'type','StaticSpikingSynapse','Cscale',Inf);

[nmc,c(2)]=add(nmc,'conn','dest',p_lif,'src',p_sin,...
               'Cscale',1,'Wscale',5);

[nmc,c(3)]=add(nmc,'conn','dest',p_hh,'src',p_ain,...
               'type','StaticAnalogSynapse','Wscale',0.2);


[nmc,c(4)]=add(nmc,'conn','dest',p_lif,'src',p_lif,...
               'SH_W',0.5,'lambda',2.5,'Wscale',2);

[nmc,c(5)]=add(nmc,'conn','dest',p_sig,'src',p_sig,...
               'SH_W',0.5,'lambda',2,'type','StaticAnalogSynapse');

[nmc,c(7)]=add(nmc,'conn','dest',p_hh,'src',p_hh,...
               'SH_W',0.5,'lambda',1);

[nmc,c(6)]=add(nmc,'conn','dest',p_hh,'src',p_lif,...
               'SH_W',0.5,'lambda',10,'type','StaticSpikingSynapse');




S = empty_stimulus('nChannels',3,'Tstim',1);

S.channel(1).data    = 1*rand(1,10);
S.channel(1).spiking = 1;

S.channel(2).data    = 1*rand(1,20);
S.channel(2).spiking = 1;

S.channel(3).dt      = 0.005;
S.channel(3).data    = 1+sin(2*pi*10*[0:S.channel(3).dt:1]);
S.channel(3).spiking = 0;


nmc = record(nmc,'Pool',p_lif,'Field','spikes');
nmc = record(nmc,'Volume',[6 1 1; 8 3 1],'Field','Vm');
nmc = record(nmc,'Volume',[10 1 1; 12 3 1],'Field','Vm');

figure(1);
plot_stimulus(S);
%print -depsc2 tut_stim.eps

R=simulate(nmc,1,S);


figure(2);
plot_response(R);
%print -depsc2 tut_resp.eps

