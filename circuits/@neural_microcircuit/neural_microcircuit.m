function this = neural_microcircuit(varargin)

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

%
% Evaluate all other arguments.
% This is intended to be able to set off-default values.
%
%s=1;
%while s<= length(varargin)
%  a=varargin{s};
%  if ~isempty(findstr(a,'='))
    % We assume that the argument defines an assignment
    % like 'NOISE=0.004'.
%    eval(sprintf('this.%s;',a)); s=s+1;
%  else
    % Here wwe assume that the argument 'varargin{s}'
    % gives the name of the parameter and
    % 'varargin{s+1}' gives its value.
%    eval(sprintf('this.%s=varargin{s+1};',a)); s=s+2;
%  end
%end


this.public_properties = { 'dt_sim' 'rndinit' 'randSeedSim' 'randSeedConn'};

csim('destroy');
csim('init');

csim('set','dt',this.dt_sim);
csim('set','randSeed',ceil(rand*1e6));
csim('set','spikeOutput',0);

[pathstr,name,ext] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end

