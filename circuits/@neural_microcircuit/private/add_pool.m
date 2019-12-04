function [nmc, p, nidx] = add_pool(nmc, varargin)

% ADD_POOL Creates a pool of neurons
%
%  Syntax
%
%    [nmc, p, nidx] = add_pool(nmc, parameters)
%
%  Arguments
%
%         nmc - neural microcircuit object
%  parameters - ..., 'paramter name', parameter, ...
%               pairs to override the default parameters of neurons and neuron pools
%               (see default_parameters.m for possible parameters)
%               'origin' is a required parameter and denotes a 1x3 position vector in space
%               (pools of neurons should not overlap in space!)
%
%           p - pool handle (number of the pool)
%        nidx - csim indices of the neurons created by this call
%
%  Description
%
%    [nmc, p, nidx] = add_pool(nmc, parameters) creates a pool of neurons and adds it to the
%    neural_microcircuit object/current csim network.
%    Pools are created according to the default parameters given in default_parameters.m.
%    However, one can override the default values of the pools and neurons
%
%  See also Tutorial on circuit construction (www.lsm.tugraz.at)
%
%  Author
%
%    Christian Naeger, naeger@igi.tu-graz.ac.at



% MODIFIED BY MICHAEL PFEIFFER, 07/01/2004


global_definitions;


np = nmc.def.pool;

p = -1;


if mod(length(varargin), 2) ~= 0
  fprintf('Syntax Error: Incorrect number of Parameters. Command ignored.\n');
  return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check parameters and override defaults
%

a = strmatch('origin', lower(strvcat(varargin{1:2:end})), 'exact');
if length(a) == 1
  a=(a-1)*2+1;
  b = varargin{a+1};
  if isnumeric(b) & all(size(b) == [1 3])
    position = b;
    varargin([a, a+1]) = [];
  else
    fprintf('''Origin'' must be a 1x3 vector denoting the location of the pool in a 3D world. Command ignored.\n');
    return
  end
else
  fprintf('You must provide one 1x3 vector ''Origin''. Command ignored.\n');
  return
end


a = strmatch('type', lower(strvcat(varargin{1:2:end})), 'exact');
if length(a) == 1
  a=(a-1)*2+1;
  np.type = varargin{a+1};
  varargin([a, a+1]) = [];
elseif length(a) > 1
  fprintf('You can only supply one ''type'' argument. Command ignored.\n');
  return
end


a = strmatch('size', lower(strvcat(varargin{1:2:end})), 'exact');
if length(a) == 1
  a=(a-1)*2+1;
  b = varargin{a+1};
  if isnumeric(b) & all(size(b) == [1 3]) & prod(b) >= 1
    np.size = b;
    varargin([a, a+1]) = [];
  else
    fprintf('''size'' must be a 1x3 vector denoting the size of the pool. Command ignored.\n');
    return
  end
elseif length(a) > 1
  fprintf('You can only supply one ''size'' argument. Command ignored.\n');
  return
end


a = strmatch('frac_EXC', (strvcat(varargin{1:2:end})), 'exact');
if length(a) == 1
  a=(a-1)*2+1;
  b = varargin{a+1};
  if isnumeric(b) & b>=0 & b<=1
    np.frac_EXC = b;
    varargin([a, a+1]) = [];
  else
    fprintf('''frac_EXC'' must be a double in the range [0, 1]. Command ignored.\n');
    return
  end
elseif length(a) > 1
  fprintf('You can only supply one ''frac_EXC'' argument. Command ignored.\n');
  return
end


s = 1;
while s <= length(varargin)
  a = varargin{s};
  if ischar(a)
    eval(sprintf('[np.%s]=deal(varargin{s+1});', a));
    s = s+2;
  else
    fprintf('Syntax Error: You must provide parameters of the form ''ParameterName'', ParameterValue. Command ignored.\n');
    return
  end
end

fn = fieldnames(np);
if ~all(ismember(fn, fieldnames(nmc.def.pool)))
  up = find(~ismember(fn, fieldnames(nmc.def.pool)));
  fprintf('Unknown parameter(s): \n');
  fprintf('%s \n', fn{up});
  fprintf('\nAllowed parameters are: \n');
  kp = fieldnames(nmc.def.pool);
  fprintf('%s \n', kp{:});
  fprintf('\nCommand ignored.\n');
  return
end


for i = 1:length(fn)
  if ~ischar(eval(sprintf('nmc.def.pool.%s', fn{i})))
    if any(size(eval(sprintf('np.%s', fn{i}))) ~= size(eval(sprintf('nmc.def.pool.%s', fn{i}))))
      fprintf('Parameter size mismatch (%s must have size [%i %i]). Command ignored.\n', ...
	  fn{i}, size(eval(sprintf('nmc.def.pool.%s', fn{i})), 1), size(eval(sprintf('nmc.def.pool.%s', fn{i})), 2) );
      return
    end
  end
end

np.pos = position;
np.neuronIdx = [];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% create the neurons
%


% randomly distribute exc. and inh. neurons over the grid
neuronType = INH * ones(np.size);
neuronType(rand(np.size) <= np.frac_EXC) = EXC;
neuronType = neuronType(:);

np.neuronIdx = csim('create', np.type, prod(np.size));

ndesc = csim('get', np.neuronIdx(1));


% BEGIN MICHAEL PFEIFFER
np.isInput = 0;
if ~isempty(strfind(np.type, 'Input')) | ~isempty(strfind(np.type, 'Feedback'))
  np.isInput = 1;
end
% END MICHAEL PFEIFFER


% set parameters
for t = [EXC INH]

  idx = np.neuronIdx(neuronType == t);
  nidx = length(idx);

  if nidx > 0
    csim('set', idx, 'type', t);

    fn = fieldnames(np.Neuron(t));
    fi = find(ismember(fn, ndesc.fields));


    for i = 1:length(fi)
      para = eval(sprintf('np.Neuron(t).%s', fn{fi(i)}));
      if isnumeric(para) & length(para) == 2
	para = sort(para);
	csim('set', idx, fn{fi(i)}, para(1) + diff(para)*rand(1, nidx));
      else
	csim('set', idx, fn{fi(i)}, para);
      end
    end

  end

end

fn = fieldnames(np.Neuron(1));
fn = { fn{:} 'type' };
fi = find(ismember(fn, ndesc.fields));
if length(fi) ~= length(ndesc.fields)
  ii=find(~ismember(ndesc.fields,fn));
  notset = ndesc.fields(ii);
  fprintf(sprintf('Warning: no values specified/available for fields:%s\n',sprintf(' %s',notset{:})));
end

npara = varargin(1:2:end);
ignore = {};
for i=1:length(npara)
  a = strfind(npara{i},'.');
  if isempty(a)
    field = [];
    % field = npara{i};
  else
    field = npara{i}(a(1)+1:end);
  end

  if ~ismember(field, ndesc.fields)
    ignore{length(ignore)+1} = field;
  end
end

if length(ignore) > 0
  fprintf('Ignoring the following field(s):');
  fprintf(' %s', ignore{:});
  fprintf('\n');
  fprintf('\nKnown fields for %s are:', np.type);
  fprintf(' %s', ndesc.fields{:});
  fprintf('\n');
end


nmc.pool = [nmc.pool np];
nidx = np.neuronIdx;

p = length(nmc.pool);


if VERBOSE_LEVEL > 0
  fprintf('Created %ix%ix%i pool %i (Frac_EXC=%g, Iinject=%g-%g): %i %s  \n', ...
      np.size(1), np.size(2), np.size(3), p, ...
      np.frac_EXC, np.Neuron(EXC).Iinject(1), np.Neuron(EXC).Iinject(2), ...
      length(np.neuronIdx), np.type);
end

