function [CT] = conv_circ_temp(CT,E);
%CONV_CIRC_TEMP conversion between different microcircuit types.
%   CT = GEN_CIRC_TEMP(CT,E) converts a microcircuit E exported from the function
%   CSIM into a small_microcircuit object CT. Input arguments are
%
%  	 CT   ... empty small_microcircuit object
%	 E    ... microcircuit that was exported from the function CSIM with the
%   		  command E = CSIM('export')
%
%
%   See also SMALL_MICROCIRCUIT/GENERATE
%
%   Author: Stefan Haeusler, 10/2002, haeusler@igi.tu-graz.ac.at

additional_definitions;

% find neurons
Neurons = strmatch('LifNeuron',{E.object(:).type},'exact') - 1;
neuron_type = ones(1,length(Neurons)); % default type is neur_type_str{1}


% find synapses

SS = strmatch('StaticSpikingSynapse',{E.object(:).type},'exact');
DS = strmatch('DynamicSpikingSynapse',{E.object(:).type},'exact');

AS = [SS DS] - 1; % -1 for csim index 0,...

dyn_syn = [];
dyn_syn_pre = [];
dyn_syn_post = [];
stat_syn = [];
stat_syn_pre = [];
stat_syn_post = [];

for i = 1:length(AS)

   % eliminate synapses whose pre unit is no LifNeuron 
   l = find(E.dst == AS(i));
   j = double(E.src(l)) + 1;
   k = strmatch('LifNeuron',{E.object(j).type},'exact');

   if ~isempty(k)
      if length(k) ~= 1
         error('Synapse has more than one source neurons.')
      end

      l2 = find(E.src == AS(i));
      j2 = double(E.dst(l2)) + 1;
      k2 = strmatch('LifNeuron',{E.object(j2).type},'exact');

      m = find(Neurons==E.src(l(k))); % l(k) is index 1,... of src array
                                      % Neurons and E.src have indices 0,...
                                      % m is source neuron index 1,... of Neurons array
 
      % detect ouput synapses (synapses that are no sources)

      if isempty(k2)
         n = NaN;
      else
         n = find(Neurons==E.dst(l2(k2))); % n is dest neuron index 1,... of Neurons array
      end


      % classify synapse type

      if i > length(SS)
         dyn_syn(end+1) = AS(i);
         dyn_syn_pre(end+1) = m;
         dyn_syn_post(end+1) = n;

         neuron_type(m) = 1 + (E.object(AS(i)+1).parameter(9) < 0); % detect interneurons
      else
         stat_syn(end+1) = AS(i);
         stat_syn_pre(end+1) = m;
         stat_syn_post(end+1) = n;
      end
   end
end

% import neurons

for nNeurons = 1:length(Neurons)

   par = E.object(Neurons(nNeurons)+1).parameter;
   
   CT.neuron(nNeurons).spec = 'LifNeuron';
   CT.neuron(nNeurons).type = neur_type_str{neuron_type(nNeurons)};
   CT.neuron(nNeurons).Cm = par(1);
   CT.neuron(nNeurons).Rm = par(2);
   CT.neuron(nNeurons).Vm_thresh = par(3);
   CT.neuron(nNeurons).Vm_rest = par(4);
   CT.neuron(nNeurons).Vm_reset = par(5);
   CT.neuron(nNeurons).Vm_init = par(6);
   CT.neuron(nNeurons).Abs_refr = par(7);
   CT.neuron(nNeurons).Noise = par(8);
   CT.neuron(nNeurons).I_base = par(9);
end


% std for neuron parameters

fn = fieldnames(CT.neuron_std);
for i = 1:length(fn)
   eval(sprintf('neuron_std.%s = 0;',fn{i}))
end
CT.neuron_std(1:length(Neurons)) = neuron_std;


% import dynamic synapses

conn = syn_parameters;
   

for nSyn = 1:length(dyn_syn)

   par = E.object(dyn_syn(nSyn)+1).parameter;

   CT.synapse(nSyn).spec = 'DynamicSpikingSynapse';
   CT.synapse(nSyn).Pre_n = dyn_syn_pre(nSyn);
   CT.synapse(nSyn).Post_n = dyn_syn_post(nSyn);
   CT.synapse(nSyn).U = par(1);
   CT.synapse(nSyn).D = par(2);
   CT.synapse(nSyn).F = par(3);
   CT.synapse(nSyn).u_inf = par(4);
   CT.synapse(nSyn).r_inf = par(5);
   CT.synapse(nSyn).p = par(7);
   CT.synapse(nSyn).Tau = par(8);
   CT.synapse(nSyn).A = par(9);
   CT.synapse(nSyn).Delay = par(10);

   % find closest synapse type
   for i = 1:length(conn)
      v = (conn(i).U - par(1))^2 + (conn(i).D - par(2))^2 + (conn(i).F - par(3))^2;
      if isempty(v)
         conn_err(i)= NaN;
      else
         conn_err(i) = v;
      end
   end
   [i,j] = min(conn_err);
 
   CT.synapse(nSyn).type = syn_type_str{j};


end

% import static synapses

for nSyn = 1:length(stat_syn)

   par = E.object(stat_syn(nSyn)+1).parameter;

   CT.synapse(nSyn + length(dyn_syn)).spec = 'StaticSpikingSynapse';
   CT.synapse(nSyn + length(dyn_syn)).type = 'st';
   CT.synapse(nSyn + length(dyn_syn)).Pre_n = stat_syn_pre(nSyn);
   CT.synapse(nSyn + length(dyn_syn)).Post_n = stat_syn_post(nSyn);
   CT.synapse(nSyn + length(dyn_syn)).A = par(3);
   CT.synapse(nSyn + length(dyn_syn)).Delay = par(4);
   CT.synapse(nSyn + length(dyn_syn)).Tau = par(2);
   CT.synapse(nSyn + length(dyn_syn)).p = par(1);
end

% std for synaptic parameters

fn = fieldnames(CT.synapse_std);
for i = 1:length(fn)
   eval(sprintf('synapse_std.%s = 0;',fn{i}))
end
CT.synapse_std(1:length(CT.synapse)) = synapse_std;

% microcircuit name

CT.name = 'CE';

% input neuron indices

CT.INidx = [1:length(Neurons)];

% only last neuron is output neuron 

CT.OUTidx = length(Neurons);

% rescaling 

CT.Ascale = 1.0;

