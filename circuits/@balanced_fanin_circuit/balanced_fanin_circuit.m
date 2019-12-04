function this = balanced_fanin_circuit(varargin)
% balanced_fanin_circuit Class for circuits with balanced exc/inh and const. fan in.

this.def_comment = 'default parameters for pools (+neurons) and connections (+synapses)';
this = default_parameters(this);

this.dt_sim   = 2e-4;
this.dt_sim_comment = 'simulation time step [s]';

this.randSeedConn = ceil(rand*1e6);
this.randSeedConn_comment = 'random seed for making the random connections (private/conn.c) [integer]';

this.pool = struct([]);
this.pool_comment = 'pool of neurons';

this.conn = struct([]);
this.conn_comment = 'connection (i.e. synapses) between two pools or within one pool';

this.recorder = struct([]);
this.recorder_comment = 'recorder';

this.gui.pool = struct([]);
this.gui_comment = 'handles for the gui';

this.csimNet  = []; % needed for save
this.csimNet_comment = 'structure needed for save';


this.public_properties = { 'dt_sim' 'rndinit' 'randSeedSim' 'randSeedConn'};

csim('destroy');
csim('init');

csim('set','dt',this.dt_sim);
csim('set','randSeed',ceil(rand*1e6));
csim('set','spikeOutput',0);

[pathstr,name,ext,versn] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end

