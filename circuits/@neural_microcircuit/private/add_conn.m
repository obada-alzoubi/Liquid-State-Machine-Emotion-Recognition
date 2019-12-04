function [nmc, c, synidx, src_pos, dest_pos] = add_conn(nmc, varargin)

% ADD_CONN Creates a connection (set of synapses) between two pools or 3D volumes of neurons
%
%  Syntax
%
%    [nmc, c, synidx] = add_conn(nmc, parameters)
%
%  Arguments
%
%         nmc - neural microcircuit object
%  parameters - ..., 'paramter name', parameter, ...
%               pairs to override the default parameters of connections and synapses
%               (see default_parameters.m for possible parameters)
%               'dest' and 'src' are additional required parameters and denote the
%               destination and source of the connection (either as pool handle or 3D Volume)
%
%           c - connection handle (number of the connection)
%      synidx - csim indices of the synapses created by this call
%
%  Description
%
%    [nmc, c, synidx] = add_conn(nmc, parameters) creates a connection (synapses) between two
%    pools or 3D-regions in space according to the default parameters given in default_parameters.m.
%    However, one can override the default values of the connection and the synapses.
%
%  See also Tutorial on circuit construction (www.lsm.tugraz.at)
%
%  Author
%
%    Christian Naeger, naeger@igi.tu-graz.ac.at

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
  nc.lambda = inf;
end


% BEGIN ---------- MJR 11/2004
% "topographic" connectivity
% 
topo='';
a = strmatch('special', lower(strvcat(varargin{1:2:end})), 'exact');
if length(a)==1
  a=(a-1)*2+1;
  b = varargin{a+1}; 
  switch lower(b)
   case {'topo','topographic','topo_middle'}
    topo=b;
    %shift in the middle (1 means yes)
    %assumes gridsize to be [1 1 1];
    shift_pos = [1 1 1];
   case {'topo_superficial','topographic_superficial'}
    topo=b;
    shift_pos = [0 0 0];
   case {'none','nothing'}
   otherwise
     fprintf('Unknown special argument "%s". Command ignored.\n', b);
     return
  end
  varargin([a,a+1])=[];
end

% END ---------- MJR 11/2004



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

% BEGIN -- MJR 3/2005
% allow 2-tupels and single values for lambda

%lambda source neuron type specific ([INH EXC])
%  if length(nc.lambda)==1
%    nc.lambda(2) = nc.lambda(1);
%  end
% END   ---------- MJR  3/2005



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

    
  if isempty(dest_neur) | isempty(src_neur)
    fprintf('Destination or source region empty. Command ignored. \n');
    return
  end

  
  
% BEGIN ---------- MJR 11/2004

% "topographic" connectivity by putting the source vol virtually inside
  % the dest vol.
  % lambda accounts for arbor size
  if any(topo)
    %for plotting
    doplot=0;
    if doplot== 1
      old_src_pos=src_pos;
    end
    
    %offset 
    %WARNING assumes neurons to lie on a 1,1,1 grid
    src_pos(:,end+1)= shift_pos'+ src(1,:)';

    sz = [1,size(src_pos,2)];
    
    %transformation to relative coordinates
    %the [1 1 1] (=shift_pos) is for the shift in the middle (s.b.)
    c =   repmat((src(2,:) + shift_pos - src(1,:))',sz);
    c(c==0)=1;
    p1 =  repmat(src(1,:)',sz);
    src_pos = (src_pos - p1)./c;

    %transformation to dest volume
    p1 =  repmat(dest(1,:)',sz);
    c =   repmat((dest(2,:) - dest(1,:))',sz);
    c(c==0)=1;

    src_pos = src_pos.* c;
    
    %accounts for the right shift direction if dest smaller than src
    sgn = src(2,:) - src(1,:) <= dest(2,:) - dest(1,:);
    sgn = sign(sgn-0.5)';
    %add the transformed offset
    src_pos = src_pos(:,1:end-1) + repmat(sgn.*src_pos(:,end)/2,sz - [0,1]) + p1(:,1:end-1);
    
    clear c p1
    
    %plotting
    if doplot
      figure
      plot3(old_src_pos(1,:),old_src_pos(2,:),old_src_pos(3,:),'r.',...
          dest_pos(1,:),dest_pos(2,:),dest_pos(3,:),'b.',...
          src_pos(1,:),src_pos(2,:),src_pos(3,:),'ro');
      clear old_src_pos;
    end
  end

% END ---------- MJR 11/2004






  dest_type = csim('get', dest_neur, 'type');
  src_type  = csim('get', src_neur, 'type');

  SH = [nc.SH_W nc.SH_UDF nc.SH_delay];

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

      if ~isempty(dn) & ~isempty(sn)

        nc.C(syn) = nc.C(syn) * nc.Cscale;
        nc.Synapse(syn).W = nc.Synapse(syn).W * nc.Wscale;
        nc.Synapse(syn).Wex = nc.Synapse(syn).Wex * nc.Wscale;
        nc.Synapse(syn).Aneg = nc.Synapse(syn).Aneg * nc.Wscale;
        nc.Synapse(syn).Apos = nc.Synapse(syn).Apos * nc.Wscale;
        nc.Synapse(syn).A = nc.Synapse(syn).A * nc.Wscale;

        
       
        % ====> call a fast C routine conn.mexglx to calculate which neurons are actually connected (lambda) !!!!
        [post, pre] = conn(dn, dp, sn, sp, nc.C(syn), nc.lambda, nmc.randSeedConn);
  
            
        
        if length(post) > 0 & length(pre) > 0
          
          % delete self loops
          self = (post == pre);
          post = post(1, ~self);
          pre = pre(1, ~self);
          
          % connect actually creates the synapses and sets the parameters
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

      if ~isempty(field) && ~ismember(field, sdesc.fields)
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
  synidx = nc.synapseIdx;

  c = length(nmc.conn);


  if VERBOSE_LEVEL > 0

    fprintf('Created %s connection %i (Cscale=%g, Wscale=%g, SH_W=%g, SH_UDF=%g, SH_delay=%g): %i %s (lambda=%d)', ...
	topo, c, nc.Cscale, nc.Wscale, SH(1), SH(2), SH(3), nsynapses, nc.type, nc.lambda);
    fprintf('\n');
  end


else

  fprintf('Cscale, Wscale or lambda <= 0. Command ignored. \n');
  return

end

