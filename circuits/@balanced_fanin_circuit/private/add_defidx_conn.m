function [nmc, c] = add_defidx_conn(nmc, connType, varargin)


global_definitions;

nc = nmc.def.conn;

c = -1;

if mod(length(varargin), 2) ~= 0
  fprintf('Syntax Error: Incorrect number of Parameters. Command ignored.\n');
  return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% find dest and src parameters
%


a = strmatch('src', lower(strvcat(varargin{1:2:end})), 'exact');
if ~isempty(a)
   a=(a-1)*2+1;
   src = varargin{a+1}; 
   if ~all(size(src)==[1 4])
      fprintf('''src'' must be a cell array of size [1 4]. Command ignored.\n');
      return
   end
   varargin([a, a+1]) = [];
else
  fprintf('You must provide a ''src'' index array for the connection. Command ignored.\n');
  return
end

if ~isempty(a)
   a = strmatch('dest', lower(strvcat(varargin{1:2:end})), 'exact');
   a=(a-1)*2+1;
   dest = varargin{a+1}; 
   if ~all(size(dest)==[1 4])
      fprintf('''dest'' must be a cell array of size [1 4]. Command ignored.\n');
      return
   end
   varargin([a, a+1]) = [];
else
  fprintf('You must provide a ''dest'' index array for the connection. Command ignored.\n');
  return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% override default parameters
%


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

if ~isempty(nc.Wscale) & (nc.Wscale > 0) 
  
  SH = [nc.SH_W nc.SH_UDF nc.SH_delay];

  % create correct neuron index assignment
  
  offset = 0;
  nidxass = [];
  for nP = 1:length(nmc.pool)
     idx = csim('get',nmc.pool(nP).neuronIdx,'type');
     idxE = find(idx==EXC)-1; 
     idxI = find(idx==INH)-1; 
     nidxass = [nidxass idxE+offset idxI+offset];
     offset = length(nidxass);
  end

  nsynapses = 0;
  for a = [INH EXC]
    for b = [INH EXC]

      syn = (a-1)*2+b;  % see etc/global_definitions.m

      pre = nidxass(src{syn}'+1);
      post = nidxass(dest{syn}'+1);

      % check that neuron types are the correct ones for this connection

      if length(pre)
         preneurontype = csim('get',unique(pre),'type');
      else 
         preneurontype = [];
      end

      if length(post)
         postneurontype = csim('get',unique(post),'type');
      else
         postneurontype = [];
      end

      if any(preneurontype ~= b) | any(postneurontype ~= a)
         fprintf('%i/%i:\n',a,b)
         disp(sum(postneurontype ~= a))
         disp(sum(preneurontype ~= b))
         error('Synapse type doesnt match neuron types!') 
      end

      synapses = [];

      nc.Synapse(syn).W = nc.Synapse(syn).W * nc.Wscale;
      nc.Synapse(syn).Wex = nc.Synapse(syn).Wex * nc.Wscale;
      nc.Synapse(syn).Aneg = nc.Synapse(syn).Aneg * nc.Wscale;
      nc.Synapse(syn).Apos = nc.Synapse(syn).Apos * nc.Wscale;
      nc.Synapse(syn).A = nc.Synapse(syn).A * nc.Wscale;

      if length(pre) > 0 & (length(pre) == length(post))

          % delete self loops
          self = (post == pre);
          post = post(1, ~self);
          pre = pre(1, ~self);

          synapses = connect(post, pre, nc.type, SH, nc.Synapse(syn), nc.constW, nc.Wsum(syn), nc.rescale);
          nsynapses = nsynapses + length(synapses);
      end
      
      nc.synapseIdx = [nc.synapseIdx synapses];
    end
  end
  
  
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

  c = length(nmc.conn);
  
  
  if VERBOSE_LEVEL > 0 
    
    fprintf('Created connection %i (Cscale=%g, Wscale=%g, SH_W=%g, SH_UDF=%g, SH_delay=%g): %i %s (lambda=%i)', ...
	c, nc.Cscale, nc.Wscale, SH(1), SH(2), SH(3), nsynapses, nc.type, nc.lambda); 
    fprintf('\n');
  end 

  
else
  
  fprintf('Wscale <= 0. Command ignored. \n');
  return

end

