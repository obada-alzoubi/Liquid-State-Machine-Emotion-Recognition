function nmc = set(nmc, varargin)


global_definitions;


switch varargin{1}
  
  case 'Pool'
    if length(varargin) < 2 | ~isnumeric(varargin{2}) | varargin{2} > length(nmc.pool)
      fprintf('You must specify a pool (there are %i pools). Command ignored.\n', length(nmc.pool));
      return
    end
    s = 3;
    while s <= length(varargin)
      a = varargin{s};
      v = varargin{s+1};
      csim('set', nmc.pool(varargin{2}).neuronIdx, a, v);
      % eval(sprintf('[nmc.pool(varargin{2}).Neuron(:).%s]=deal(v);', a)); 
      s = s+2;
    end
    
  case 'Conn'
    if length(varargin) < 2 | ~isnumeric(varargin{2}) | varargin{2} > length(nmc.conn)
      fprintf('You must specify a connection (there are %i connections). Command ignored.\n', length(nmc.conn));
      return
    end
    s = 3;
    while s <= length(varargin)
      a = varargin{s};
      v = varargin{s+1};
      csim('set',[nmc.conn(varargin{2}).synapseIdx(:)], a, v);
      % eval(sprintf('[nmc.conn(varargin{2}).Synapse(:).%s]=deal(v);', a)); 
      s = s+2;
    end
    
  case 'Recorder'
    if length(varargin) < 2 | ~isnumeric(varargin{2}) | varargin{2} > length(nmc.recorder)
      fprintf('You must specify a recorder (there are %i recoders). Command ignored.\n', length(nmc.recorder));
      return
    end
    s = 3;
    while s <= length(varargin)
      a = varargin{s};
      v = varargin{s+1};
      csim('set', nmc.recorder(varargin{2}).idx, a, v);
      eval(sprintf('nmc.recorder(varargin{2}).%s=v;', a)); 
      s = s+2;
    end
    
  otherwise
    s = 1;
    while s <= length(varargin)
      a = varargin{s};
      v = varargin{s+1};
      eval(sprintf('nmc.%s=v;', a));
      s = s+2;
    end
  
end 

