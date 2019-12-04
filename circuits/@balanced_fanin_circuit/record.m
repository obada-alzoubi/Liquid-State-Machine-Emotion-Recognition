function [nmc, r] = record(nmc, varargin)

global_definitions;


nr.idx = [];
nr.dt = [];
nr.Tprealloc = [];
nr.Field = [];
nr.rec_idx = [];

s = 1;
while s <= length(varargin)
  a = varargin{s};
  b = varargin{s+1};
  
  switch a
    
    case 'Conn'
      for i = 1:length(b)
	if b(i) > length(nmc.conn)
	  fprintf('There are only %i connections. Command ignored.\n', length(nmc.conn));
	  return
	end
	nr.rec_idx = [nr.rec_idx nmc.conn(b(i)).synapseIdx];
      end
      
    case 'Pool'
      for i = 1:length(b)
	if b(i) > length(nmc.pool)
	  fprintf('There are only %i pools. Command ignored.\n', length(nmc.pool));
	  return
	end
	nr.rec_idx = [nr.rec_idx nmc.pool(b(i)).neuronIdx];
      end
      
    case 'Volume'
      if ~all(size(b) == [2 3])
	fprintf('Volume must be a 2x3 Matrix. Command ignored.\n');
	return
      end
      [idx,pos] = vol2neur(nmc,b);
      if isempty(idx)
	fprintf('Warning: Volume is empty!\n');
      else      
	nr.rec_idx = [nr.rec_idx idx];
      end
      
    case 'Field'
      if ~isempty(nr.Field)
	fprintf('You can only supply one ''Field'' per recorder. Command ignored.\n');
	return
      end
      nr.Field = b;
      
    case 'dt'
      if ~isempty(nr.dt)
	fprintf('You can only supply one ''dt'' per recorder. Command ignored.\n');
	return
      end
      nr.dt = b;
      
    case 'Tprealloc'
      if ~isempty(nr.Tprealloc)
	fprintf('You can only supply one ''Tprealloc'' per recorder. Command ignored.\n');
	return
      end
      nr.Tprealloc = b;
      
    otherwise
      fprintf('Syntax: nmc = record(nmc, ''ParameterName'', ParameterValue, ...);\n');
      fprintf('        nmc is the name of the neural microciruit object\n');
      fprintf('        ''ParameterName'', ParameterValue can be a combination of: \n');
      fprintf('        ''Pool'', vector of pools\n');
      fprintf('        ''Conn'', vector of connections\n');
      fprintf('        ''Volume'', 2x3 matrix defining a 3D volume\n');
      fprintf('        ''Field'', the field to be recorded (or ''spikes'')\n');
      fprintf('        ''dt'', the recording timestep\n');
      fprintf('        ''Tprealloc'', the pre-allocation for the recorder\n');
      fprintf('Command ignored.\n');
      return
      
  end
  s = s+2;
end


if isempty(nr.Field)
  fprintf('You must provide a ''Field'' to be recorded. Command ignored.\n');
  return
end


nr.idx = csim('create', 'MexRecorder', 1);
csim('set', nr.idx, 'commonChannels', 0);

% check all rec.idx if they have r.field ???????????????

csim('connect', nr.idx, nr.rec_idx, nr.Field);

if ~isempty(nr.dt), csim('set', nr.idx, 'dt', nr.dt), end
if ~isempty(nr.Tprealloc), csim('set', nr.idx, 'Tprealloc', nr.Tprealloc), end

nmc.recorder = [nmc.recorder nr];

r = length(nmc.recorder);

if VERBOSE_LEVEL > 0
  fprintf('Created recorder %i for %i objects (Field=%s)\n', ...
	r, length(nr.rec_idx), nr.Field); 
end

