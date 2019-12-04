function [nmc, c] = add_conn(nmc, connType, varargin)

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

destpool = []; srcpool = [];

a = strmatch('dest', lower(strvcat(varargin{1:2:end})), 'exact');
if length(a) == 1
  a=(a-1)*2+1;
  b = varargin{a+1};
  if isnumeric(b) & (all(size(b) == [1 1]) | all(size(b) == [2 3]))
    if all(size(b) == [1 1])
      if b > length(nmc.pool);
	fprintf('There are only %i pools of neurons. Command ignored.\n', length(nmc.pool));
	return
      end
      destpool = b;
      dest = [nmc.pool(b).pos; nmc.pool(b).pos + nmc.pool(b).size-1];
    else
      dest = b;
    end
    dest = sort(dest);
    varargin([a, a+1]) = [];
  else
    fprintf('''dest'' must be a pool number or a matrix [x1 y1 z1; x2 y2 z2] specifying a 3D region. Command ignored.\n');
    return
  end
else
  fprintf('You must provide a ''dest'' (region or pool) for the connection. Command ignored.\n');
  return
end


a = strmatch('src', lower(strvcat(varargin{1:2:end})), 'exact');
if length(a) == 1
  a=(a-1)*2+1;
  b = varargin{a+1};
  if isnumeric(b) & (all(size(b) == [1 1]) | all(size(b) == [2 3]))
    if all(size(b) == [1 1])
      if b > length(nmc.pool);
	fprintf('There are only %i pools of neurons. Command ignored.\n', length(nmc.pool));
	return
      end  
      srcpool = b;
      src = [nmc.pool(b).pos; nmc.pool(b).pos + nmc.pool(b).size-1];
    else
      src = b;
    end
    src = sort(src);
    varargin([a, a+1]) = [];
  else
    fprintf('''src'' must be a pool number or a matrix [x1 y1 z1; x2 y2 z2] specifying a 3D region. Command ignored.\n');
    return
  end
else   
  fprintf('You must provide a ''src'' (region or pool) for the connection. Command ignored.\n');
  return
end

if isempty(srcpool) | isempty(destpool) | srcpool ~= destpool
%  nc.lambda = inf;
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

if ~isempty(nc.Cscale) & ~isempty(nc.Wscale) & (nc.Cscale > 0) & (nc.Wscale > 0) & (nc.lambda > 0)
  
  % find all neurons in the region
  dest_neur = []; src_neur = [];
  dest_pos = []; src_pos = [];
  for i = 1:length(nmc.pool)
    p = nmc.pool(i).pos;
    s = nmc.pool(i).size;
    
    %
    % calculate position of all neurons in pool i
    %
    [x y z] = ind2sub(s, 1:prod(s));
    x=x+p(1)-1;
    y=y+p(2)-1;
    z=z+p(3)-1;
    POS = [x; y; z];
    clear x y z
    %
    % find the overlap of pool i with destination volume
    %
    ni = all( POS  >= repmat(dest(1, :)', 1, prod(s)) & ...
	      POS  <= repmat(dest(2, :)', 1, prod(s)) );

    dest_pos  = [dest_pos POS(:,ni)];

    dest_neur = [dest_neur nmc.pool(i).neuronIdx(find(ni))];

    %
    % find the overlap of pool i with source volume
    %
    ni = all( POS >= repmat(src(1, :)', 1, prod(s)) & ...
	      POS <= repmat(src(2, :)', 1, prod(s)) );

    src_pos = [src_pos POS(:,ni)];

    src_neur  = [src_neur  nmc.pool(i).neuronIdx(find(ni))];
  end    

  %  keyboard
  
  if isempty(dest_neur) | isempty(src_neur)
    fprintf('Destination or source region empty. Command ignored. \n');
    return
  end
  
  dest_type = csim('get', dest_neur, 'type');
  src_type  = csim('get', src_neur, 'type');

  SH = [nc.SH_W nc.SH_UDF nc.SH_delay];

  synStr{II} = 'II';
  synStr{EI} = 'EI';
  synStr{IE} = 'IE';
  synStr{EE} = 'EE';
  
  nsynapses = 0;
  for a = [INH EXC]
    for b = [INH EXC]
      
      syn = (a-1)*2+b;  % see etc/global_definitions.m

      dt = (dest_type == a);
      st = (src_type == b);

      dn = dest_neur(1, dt);
      dp = dest_pos(:, dt);
      
      sn = src_neur(1, st);
      sp = src_pos(:, st);
      
      synapses = [];

      % otherwise error if nc.C is 0
      nc.C(syn) = nc.C(syn) * nc.Cscale;

      if ~isempty(dn) & ~isempty(sn) & (nc.C(syn)~=0)

        nc.Synapse(syn).W = nc.Synapse(syn).W * nc.Wscale;
        nc.Synapse(syn).Wex = nc.Synapse(syn).Wex * nc.Wscale;
        nc.Synapse(syn).Aneg = nc.Synapse(syn).Aneg * nc.Wscale;
        nc.Synapse(syn).Apos = nc.Synapse(syn).Apos * nc.Wscale;
        nc.Synapse(syn).A = nc.Synapse(syn).A * nc.Wscale;

        switch connType
         case 'fanin'
          nSyn = min(ceil(length(sn)*nc.C(syn)),length(sn));
          nExpexted = nSyn*length(dn);

	  [post, pre] = fanin_conn(dn, dp, sn, sp, nSyn, nc.lambda, nmc.randSeedConn);

          if  nExpexted ~= length(pre)
            fprintf(['WARNING: Only generated %i/%i %s synapses.\n' ...
                     '         Expected %i %s synapses per neuron (%i).\n' ...
                     '         Increase lambda=%g or decrease conn. prob. C(%s)=%g!\n'], ...
                    length(pre),nExpexted,synStr{syn},...
                    nSyn,synStr{syn},length(dt),...
                    nc.lambda,synStr{syn},nc.C(syn));
          end

         case 'rand'

          % [post, pre] = rand_conn(dn, dp, sn, sp, nc.C(syn), nc.lambda, nmc.randSeedConn);

          [post, pre] = rand_conn(dn, dp, sn, sp, nc.C(syn), nc.lambda, rand*1e6);
          % [post, pre] = rand_conn(dn, dp, sn, sp, nc.C(syn), nc.lambda, sum(100*clock));

         case 'randpos'

          nSyn = round(length(sn)*length(dn)*nc.C(syn));

          actSyn = 0;
          synapses = [];
          while (actSyn < nSyn)         
             [post, pre] = randpos_conn(dn, dp, sn, sp, nSyn - actSyn, nc.lambda, rand*1e6);

             % check if synapses exist already
             preNeuron = []; delSynIdx = [];
             for nS = 1:length(post)
                [preSyn,postSyn] = csim('get',post(nS),'connections'); 
                if (length(preSyn)>0)
                   for nS2 = 1:length(preSyn) 
                      [preNeuron(nS2),dummy] = csim('get',preSyn(nS2),'connections'); 
                   end
                   if any(preNeuron==pre(nS))
                      delSynIdx(end+1) = nS;
                  end
                end
             end
             if ~isempty(delSynIdx)
                warning(sprintf('%i synapses deleted to avoide multiple targeting.\n',length(delSynIdx))) 
                pre(delSynIdx) = [];
                post(delSynIdx) = [];
             end

             part_synapses = connect(post, pre, nc.type, SH, nc.Synapse(syn), nc.constW, nc.Wsum(syn), nc.rescale);
             nsynapses = nsynapses + length(part_synapses); % total synapses
             actSyn = actSyn + length(part_synapses); % only one type (e.g. EE)

             synapses = [synapses part_synapses];
          end 
          post = [];
          pre = [];

         case 'defidxconn'
          keyboard
 

	 otherwise
          fprintf('WARNING: Unknown connection type (%s). Command Ignored.',connType);
          return;
          
        end
        
        
        if length(post) > 0 & length(pre) > 0

          % delete self loops
          self = (post == pre);
          post = post(1, ~self);
          pre = pre(1, ~self);

          synapses = connect(post, pre, nc.type, SH, nc.Synapse(syn), nc.constW, nc.Wsum(syn), nc.rescale);
          nsynapses = nsynapses + length(synapses);
        end
        
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
  
  fprintf('Cscale, Wscale or lambda <= 0. Command ignored. \n');
  return

end

