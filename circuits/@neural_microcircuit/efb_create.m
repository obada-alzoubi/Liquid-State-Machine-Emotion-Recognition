function [nmc, nconn] = efb_create(nmc, varargin)

% EFB_CREATE Creates excitatory feedback loops
%
%  Description
%
%    EXPERIMENTAL !!!
%
%  Author
%
%    Christian Naeger, naeger@igi.tu-graz.ac.at


global_definitions;


nc = nmc.def.conn;

nconn = -1;

if mod(length(varargin), 2) ~= 0
  fprintf('Syntax Error: Incorrect number of Parameters. Command ignored.\n');
  return
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% find pool and prob parameters
%


a = strmatch('pool', lower(strvcat(varargin{1:2:end})), 'exact');
if length(a) == 1
  a=(a-1)*2+1;
  p = varargin{a+1};
  if isnumeric(p) & p <= length(nmc.pool)    
    varargin([a, a+1]) = [];
  else
    fprintf('''Pool'' must be a pool number. Command ignored.\n');
    return
  end
else   
  fprintf('You must provide a ''Pool''. Command ignored.\n');
  return
end


a = strmatch('order', lower(strvcat(varargin{1:2:end})), 'exact');
if length(a) == 1
  a=(a-1)*2+1;
  depth = varargin{a+1};
  if isnumeric(depth) & all(size(depth) == [1 1]) & depth >= 1 
    varargin([a, a+1]) = [];
  else
    fprintf('''order'' must be a single integer. Command ignored.\n');
    return
  end
else   
  fprintf('You must provide a ''order''. Command ignored.\n');
  return
end


a = strmatch('prob', lower(strvcat(varargin{1:2:end})), 'exact');
if length(a) == 1
  a=(a-1)*2+1;
  b = varargin{a+1};
  if isnumeric(b) & all(size(b) == [1 1]) & b >= 0 & b <= 1
    cprob = b;
    varargin([a, a+1]) = [];
  else
    fprintf('''prob'' must be a vector [prob_order1 ...]. Command ignored.\n');
    return
  end
else   
  fprintf('You must provide a ''prob''. Command ignored.\n');
  return
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% override default parameters
%

fprintf('Will ignore Cscale, lambda, constW, Wsum, C.\n');

s = 1;
while s <= length(varargin)
  a = varargin{s};
  if ischar(a)
    eval(sprintf('[nc.%s]=deal(varargin{s+1});', a)); 
    s = s+2;
  else
    fprintf('Syntax Error: You must provide parameters of the form ''ParameterName'', ParameterValue. Command ignored.\n');
    return
  end
end


fn = fieldnames(nc);
if ~all(ismember(fn, fieldnames(nmc.def.conn)))
  up = find(~ismember(fn, fieldnames(nmc.def.conn)));
  fprintf('Unknown parameter(s): \n');
  fprintf('%s \n', fn{up});
  fprintf('\nAllowed parameters are: \n');
  kp = fieldnames(nmc.def.conn);
  fprintf('%s \n', kp{:});
  fprintf('\nCommand ignored.\n');
  return
end


for i = 1:length(fn)
  if ~ischar(eval(sprintf('nmc.def.conn.%s', fn{i})))
    if any(size(eval(sprintf('nc.%s', fn{i}))) ~= size(eval(sprintf('nmc.def.conn.%s', fn{i}))))
      fprintf('Parameter size mismatch (%s must have size [%i %i]). Command ignored.\n', ...
	  fn{i}, size(eval(sprintf('nmc.def.conn.%s', fn{i})), 1), size(eval(sprintf('nmc.def.conn.%s', fn{i})), 2) );
      return
    end
  end
end

nc.synapseIdx = [];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% create connectivity
%

fprintf('\n');


for ni = 1:length(nmc.pool(p).neuronIdx)
  
  fprintf('%i ', ni);
  
  neurIdx_start = nmc.pool(p).neuronIdx(ni);

  if csim('get', neurIdx_start, 'type') == EXC

    [preS,  postS] = csim('get', neurIdx_start, 'connections');

    S = postS;
    D = ones(1, length(postS));
    B = -1 * ones(1, length(postS));
    
    c = 1;


    % build bf search "tree" till given depth

    while c <= length(S) & D(c) < depth
      
      [preN, postN] = csim('get', S(c), 'connections');
      
      if csim('get', postN, 'type') == EXC 
	[preS, postS] = csim('get', postN, 'connections');
	
	S = [S, postS];
	D = [D, D(c)+1 * ones(1, length(postS))];
	B = [B, c * ones(1, length(postS))];
      end
      
      c = c + 1;
    end

    
    SH = [nc.SH_W nc.SH_UDF nc.SH_delay];

    nc.Synapse(EE).W = nc.Synapse(EE).W * nc.Wscale;

    
    ii = find(D == depth);
    for c = 1:length(ii)
      [preN, postN] = csim('get', S(ii(c)), 'connections');
      
      if csim('get', postN, 'type') == EXC & postN ~= neurIdx_start
	[preS, postS] = csim('get', postN, 'connections');
	
	fb = 0;
	
	for s = 1:length(postS)
	  [preN2, postN2] = csim('get', postS(s), 'connections');
	  
	  if postN2 == neurIdx_start
	    fb = 1;
	  end
	end
	
	if fb == 0 & rand(1,1) <= cprob
	  nc.synapseIdx = [nc.synapseIdx, ...
		connect(neurIdx_start, postN, nc.type, SH, nc.Synapse(EE), 0, nc.Wsum(EE), nc.rescale)];
	end
      end
    end
      
  
  end   % if type == EXC
end     % for ni

fprintf('\n');
    
% ERROR control

if length(nc.synapseIdx) > 0
  sdesc = csim('get', nc.synapseIdx(1));
  
  a = strmatch('u0', sdesc.fields, 'exact');
  if ~isempty(a)
    sdesc.fields(a) = [];
  end
  a = strmatch('r0', sdesc.fields, 'exact');
  if ~isempty(a)
    sdesc.fields(a) = [];
  end
  
  fn = fieldnames(nc.Synapse(EE));
  fn = { fn{:} 'type' };
  fi = find(ismember(fn, sdesc.fields));
  if length(fi) ~= length(sdesc.fields)
    ii=find(~ismember(sdesc.fields,fn));
    notset = sdesc.fields(ii);
    fprintf(sprintf('Warning: no values specified/available for fields:%s\n',sprintf(' %s',notset{:})));
  end
  
  spara = varargin(1:2:end);
  ignore = {};
  for i=1:length(spara)
    a = strfind(spara{i},'.');
    if isempty(a)
      field = [];
      % field = spara{i};
    else
      field = spara{i}(a(1)+1:end);
    end
    
    if ~ismember(field, sdesc.fields)
      ignore{length(ignore)+1} = field;
    end
  end
  
  if length(ignore) > 0
    fprintf('Ignoring the following field(s):');
    fprintf(' %s', ignore{:});
    fprintf('\n');
    fprintf('\nKnown fields for %s are:', nc.type);
    fprintf(' %s', sdesc.fields{:});
    fprintf('\n');
  end
end


nmc.conn = [nmc.conn nc];

nconn = length(nmc.conn);


if VERBOSE_LEVEL > 0 
  
  fprintf('Created connection %i (SH_W=%g, SH_UDF=%g, SH_delay=%g): %i %s \n', ...
      nconn, SH(1), SH(2), SH(3), length(nc.synapseIdx), nc.type); 
end 


