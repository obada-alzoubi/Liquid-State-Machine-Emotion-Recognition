function [CT] = gen_circ_temp(CT,CTName,Neurons,Synapses,parameters);
%GEN_CIRC_TEMP is a tool that helps to generate a small_microcircuit template object.
%   CT = GEN_CIRC_TEMP(NAME,N,S,PAR) generates a small microcircuit object CT. The
%   input arguments are
% 
%  	 NAME ... name of the small microcircuit template, e.g. 'C1'
%	 N    ... array of neuron type specifications, e.g. [EXZ INH EXZ ...]
%	 S    ... matrix, where each row 
%
%			[POST PRE SYN_TYPE A U D F STD]
%
% 		  defines a synaptic connection. POST and PRE are neuron
%		  indices refering to the neuron array N, SYN_TYPE is an 
%		  element of the set {EE,IEd,IEf,F1,F2,F3} and A, U, D and F
%                 are synaptic parameters. STD is defined as 
%		  [std_a std_udf std_delay].
%
%		  If A, U, D or F are NaN then the values of the specified synapse
%		  type defined in PAR.CONN are used.
%
%   	PAR   ... default parameters for the neurons and synapses generated with
%		  PAR = ALL_DEFAULT_PARAMETERS.
%
%
%   See also SMALL_MICROCIRCUIT/GENERATE
%
%   Author: Stefan Haeusler, 10/2002, haeusler@igi.tu-graz.ac.at


additional_definitions;

% check the parameters
%---------------------

% generate neuron parameters
if (size(Neurons,1)~= 1)|(ndims(Neurons)~=2)
    error('Neuron type specifications must be a row vector.')
end
nNeurons = size(Neurons,2);

if (size(Synapses,2)~=10)
    error('Synaptic connection specification matrix must have 10 columns.')
end

if ~isempty(find(Synapses(:,1:2)>nNeurons))
    error('Neuron index of a synaptic connection exceeds total number of neurons.')
end

if ~isempty(find(Synapses(:,3)>length(parameters.conn)))
    error('Invalid synapse type of a synaptic connection.')
end


% main part
%----------

neur = parameters.neur;

Rm = 1;
NOISE = parameters.NOISE;
Vresting = 0.0;

for nNeurons = 1:length(Neurons)

   ind = Neurons(nNeurons);
   CT.neuron(nNeurons).spec = 'LifNeuron';
   CT.neuron(nNeurons).type = neur_type_str{ind};
   CT.neuron(nNeurons).Vm_thresh = neur(ind).thresh;
   CT.neuron(nNeurons).Vm_reset = neur(ind).vm_reset;
   CT.neuron(nNeurons).Vm_init = neur(ind).vm_init;
   CT.neuron(nNeurons).Vm_rest = 0.0;
   CT.neuron(nNeurons).Abs_refr = neur(ind).abs_refr;
   CT.neuron(nNeurons).Cm = neur(ind).tau_m;
   CT.neuron(nNeurons).Rm = Rm;
   CT.neuron(nNeurons).I_base = neur(ind).Ibase(1)+diff(neur(ind).Ibase)*rand(1);
   CT.neuron(nNeurons).Noise = NOISE;
end


% std for neuron parameters

fn = fieldnames(CT.neuron_std);
for i = 1:length(fn)
   eval(sprintf('neuron_std.%s = 0;',fn{i}))
end
CT.neuron_std(1:length(Neurons)) = neuron_std;



% generate synapse parameters

conn = parameters.conn;

p = 1;

for nSyn = 1:size(Synapses,1)
  ind = Synapses(nSyn,3);

  SH_a = Synapses(nSyn,8);
  SH_udf = Synapses(nSyn,9);
  SH_delay = Synapses(nSyn,10);

  if isnan(Synapses(nSyn,4))
     A = conn(ind).A;
  else
     A = Synapses(nSyn,4);
  end
  A = sign(A)*bnd_gammarnd(abs(A),SH_a,abs(10*A),1,1);

  delay = bnd_normrnd(conn(ind).delay,SH_delay,0,3e-3,1,1);

  % extra option
  if isnan(Synapses(nSyn,1))
     tau = 30e-3;
  else
     tau = conn(ind).tau;
  end

  if ( ind == STATIC )

     CT.synapse(nSyn).spec = 'StaticSpikingSynapse';
     CT.synapse(nSyn).type = syn_type_str{ind};
     CT.synapse(nSyn).Pre_n = Synapses(nSyn,2);
     CT.synapse(nSyn).Post_n = Synapses(nSyn,1);
     CT.synapse(nSyn).A = A;
     CT.synapse(nSyn).Delay = delay;
     CT.synapse(nSyn).Tau = tau;
     CT.synapse(nSyn).p = p;

  elseif ( IEf <= ind <= F3 )

   if isnan(Synapses(nSyn,5))
      U = conn(ind).U;
   else
      U = Synapses(nSyn,5);
   end

   if isnan(Synapses(nSyn,6))
      D = conn(ind).D;
   else
      D = Synapses(nSyn,6);
   end

   if isnan(Synapses(nSyn,7))
      F = conn(ind).F;
   else
      F = Synapses(nSyn,7);
   end

   U = bnd_normrnd(U,SH_udf,0.05,0.95,1,1);
   D = bnd_normrnd(D,SH_udf,5e-3,5,1,1);
   F = bnd_normrnd(F,SH_udf,5e-3,5,1,1);
   U_inf = U./(1-(1-U).*exp(-1./(conn(ind).f0*F)));
   R_inf = (1-exp(-1./(conn(ind).f0*D)))./(1-(1-U_inf).*exp(-1./(conn(ind).f0*D)));
  
   CT.synapse(nSyn).spec = 'DynamicSpikingSynapse';
   CT.synapse(nSyn).type = syn_type_str{ind};
   CT.synapse(nSyn).Pre_n = Synapses(nSyn,2);
   CT.synapse(nSyn).Post_n = Synapses(nSyn,1);
   CT.synapse(nSyn).A = A;
   CT.synapse(nSyn).Delay = delay;
   CT.synapse(nSyn).Tau = tau;
   CT.synapse(nSyn).U = U;
   CT.synapse(nSyn).D = D;
   CT.synapse(nSyn).F = F;
   CT.synapse(nSyn).u_inf = U_inf;
   CT.synapse(nSyn).r_inf = R_inf;
   CT.synapse(nSyn).p = p;
  else 
    error('Unknown Synapse type!');
  end
end


% std for synaptic parameters

fn = fieldnames(CT.synapse_std);
for i = 1:length(fn)
   eval(sprintf('synapse_std.%s = 0;',fn{i}))
end
CT.synapse_std(1:size(Synapses,1)) = synapse_std;


% microcircuit name

CT.name = CTName;

% input neuron indices

CT.INidx = [1:length(Neurons)];

% only last neuron is output neuron 

CT.OUTidx = length(Neurons);

% rescaling 

CT.Ascale = parameters.Ascale;

