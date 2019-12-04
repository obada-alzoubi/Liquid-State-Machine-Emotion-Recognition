function reset(this, argRandSeed)

% RESET Resets the simulation
%
%  Syntax
%
%    reset(nmc, argRandSeed)
%
%  Arguments
%
%         nmc - neural microcircuit object
% argRandSeed - random seed
%
%  Description
%
%    reset(nmc) resets the simulation (csim) and sets all neurons to their vinit value.
%    By specifying a random seed the Matlab and csim random number generators are reset to this
%    random seed in order to generate reproducable random numbers.
%
%  See also Tutorial on circuit construction (www.lsm.tugraz.at)
%
%  Author
%
%    Christian Naeger, naeger@igi.tu-graz.ac.at

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
      if nidx > 0 && length( this.pool(p).Neuron(t).Vinit ) > 1
        vinit=this.pool(p).Neuron(t).Vinit(1) + diff(this.pool(p).Neuron(t).Vinit)*rand(1,nidx);
        csim('set',idx,'Vinit',vinit);
      end
    end
  end
end

csim('set','dt',this.dt_sim);
csim('set','randSeed', csimRandSeed);
csim('reset');
