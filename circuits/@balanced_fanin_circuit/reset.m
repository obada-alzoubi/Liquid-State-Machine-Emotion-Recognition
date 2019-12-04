function [csimout,spikes] = reset(this,argRandSeed)

if nargin < 2, argRandSeed = []; end

if ~isempty(argRandSeed)
  rand('state',argRandSeed);
  randn('state',argRandSeed);
end

csimRandSeed = ceil(rand*1e6);

global_definitions

for p=1:length(this.pool)
  if ~this.pool(p).isInput & ~isempty(strfind(this.pool(p).type,'LifNeuron'))
    neuronType = csim('get',this.pool(p).neuronIdx,'type');
    for t = [EXC INH]
      idx = this.pool(p).neuronIdx(neuronType == t);
      nidx = length(idx);
      if nidx > 0
        vinit=this.pool(p).Neuron(t).Vinit(1) + diff(this.pool(p).Neuron(t).Vinit)*rand(1,nidx);
        csim('set',idx,'Vinit',vinit);
      end
    end
  end
end

csim('set','dt',this.dt_sim);
csim('set','randSeed', csimRandSeed);
csim('reset');
