function nmc = default_parameters(nmc);


global_definitions



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% default parameters for neurons
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


neur(EXC).Cm       = 3e-8;              % membrane capacity (time-constant = C*R)
neur(INH).Cm       = 3e-8; 

neur(EXC).Rm       = 1e6;               % membrane resistance (time-constant = C*R)
neur(INH).Rm       = 1e6;

neur(EXC).Iinject  = [13.5e-9 14.5e-9]; % interval from which Ib is drawn randomly
neur(INH).Iinject  = [13.5e-9 14.5e-9]; % interval from which Ib is drawn randomly

% neur(EXC).IinjectSD = 0.0;            % standard deviation of injected current 
% neur(INH).IinjectSD = 0.0;

neur(EXC).Inoise   = [0.0 0.0];         % noise at each integration time step
neur(INH).Inoise   = [0.0 0.0];

neur(EXC).Vthresh  = [15e-3 15e-3];     % threshold of the neurons
neur(INH).Vthresh  = [15e-3 15e-3]; 

neur(EXC).Trefract = 0.003;             % absolute refractory period
neur(INH).Trefract = 0.002;

neur(EXC).Vresting = [0.0 0.0];
neur(INH).Vresting = [0.0 0.0];

neur(EXC).Vreset   = [13.8e-3 14.5e-3]; % membrane voltage after spike
neur(INH).Vreset   = [13.8e-3 14.5e-3];

neur(EXC).Vinit    = [13.5e-3 14.9e-3]; % membrane voltage at start of simulation
neur(INH).Vinit    = [13.5e-3 14.9e-3];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% default parameters for synapses
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% EXC to EXC synapses

syn(EE).W     = 30e-9;  % mean weight of synapse
syn(EE).p     = 1;      % transmission probability
syn(EE).Inoise = 0.0;   % noise added to PSC
syn(EE).U     = 0.5;    % mean dyn. U-parameter
syn(EE).D     = 1.1;    % mean dyn. D-parameter
syn(EE).F     = 0.05;   % mean dyn. F-Parameter
syn(EE).delay = 1.5e-3; % mean of axonal delay (CV is 0.1)
syn(EE).tau   = 3e-3;   % PSP time-constant (CV is 0.0)
syn(EE).f0    = 6;      % frequency used to calculate initial values for r and u of
                        % dynamic synapses: r(0) = r_inf and u(0) = u_inf
                        % see PNAS paper for equations


% EXC to INH synapses

syn(IE).W     = 60e-9;
syn(IE).p     = 1;
syn(IE).Inoise = 0.0;
syn(IE).U     = 0.05;
syn(IE).D     = 0.125;
syn(IE).F     = 1.2;
syn(IE).delay = 0.8e-3;
syn(IE).tau   = 3e-3;
syn(IE).f0    = 6;


% INH to EXC synapses

syn(EI).W     = -19e-9;
syn(EI).p     = 1;
syn(EI).Inoise = 0.0;
syn(EI).U     = 0.25;
syn(EI).D     = 0.7;
syn(EI).F     = 0.02;
syn(EI).delay = 0.8e-3;
syn(EI).tau   = 6e-3;
syn(EI).f0    = 6;


% INH to INH synapses

syn(II).W     = -19e-9;
syn(II).p     = 1;
syn(II).Inoise = 0.0;
syn(II).U     = 0.32;
syn(II).D     = 0.144;
syn(II).F     = 0.06;
syn(II).delay = 0.8e-3;
syn(II).tau   = 6e-3;
syn(II).f0    = 6;

% default parameters for STDP
syn(EE).Apos = 0.25 * 1 * syn(EE).W;
syn(EE).Aneg = 0.25 * -0.43 * syn(EE).W;
syn(EE).A    = 0.25 * 1 * syn(EE).W;
syn(EE).tauca = 100e-3;
syn(EE).gamma = 0.75;
% syn(EE).Apos = 0.2 * 1.01 * syn(EE).W;
% syn(EE).Aneg = 0.2 * -0.52 * syn(EE).W;
syn(EE).taupos = 14.8e-3;
syn(EE).tauneg = 33.8e-3;
syn(EE).tauspost = 88e-3;
syn(EE).tauspre = 28e-3;
syn(EE).mupos = 0;
syn(EE).muneg = 0;
% syn(EE).Tmin = -50e-3;
% syn(EE).Tmax = 50e-3;
syn(EE).Wex = 6 * syn(EE).W;
syn(EE).STDPgap = 0;
syn(EE).activeSTDP = 1;

syn(IE).Apos = 0;
syn(IE).Aneg = 0;
syn(IE).A = 0;
syn(IE).tauca = 0;
syn(IE).gamma = 0;
syn(IE).taupos = 0;
syn(IE).tauneg = 0;
syn(IE).tauspost = 0;
syn(IE).tauspre = 0;
syn(IE).mupos = 0;
syn(IE).muneg = 0;
syn(IE).Wex = 0;
syn(IE).STDPgap = 0;
syn(IE).activeSTDP = 0;

syn(EI).Apos = 0;
syn(EI).Aneg = 0;
syn(EI).A = 0;
syn(EI).tauca = 0;
syn(EI).gamma = 0;
syn(EI).taupos = 0;
syn(EI).tauneg = 0;
syn(EI).tauspost = 0;
syn(EI).tauspre = 0;
syn(EI).mupos = 0;
syn(EI).muneg = 0;
syn(EI).Wex = 0;
syn(EI).STDPgap = 0;
syn(EI).activeSTDP = 0;

syn(II).Apos = 0;
syn(II).Aneg = 0;
syn(II).A = 0;
syn(II).tauca = 0;
syn(II).gamma = 0;
syn(II).taupos = 0;
syn(II).tauneg = 0;
syn(II).tauspost = 0;
syn(II).tauspre = 0;
syn(II).mupos = 0;
syn(II).muneg = 0;
syn(II).Wex = 0;
syn(II).STDPgap = 0;
syn(II).activeSTDP = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% default parameters for a pool of neurons: POOL
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


pool.type = 'LifNeuron';

pool.size = [3 3 15]; % neurons in [x y z] dimension

pool.frac_EXC = 0.8;  % fraction of exc. neurons in the pool


pool.Neuron = neur;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% default parameters for connections between two pools of neurons: CONN
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


conn.type = 'DynamicSpikingSynapse';

conn.Cscale   = 1;    % scaling of maximum connection probablity
conn.Wscale   = 1;    % scaling of the A-parameter (weights of synapses)
conn.SH_W     = 0.7;  % synaptic heterogeneity for weights of synaptic connections
conn.SH_UDF   = 0.5;  % synaptic heterogeneity for parameters of synaptic dynamics
conn.SH_delay = 0.1;  % synaptic heterogeneity for delays of synaptic connections

conn.lambda(EE) = 2;      % "mean" of connection-length between neurons
conn.lambda(EI) = 2;      % "mean" of connection-length between neurons
conn.lambda(IE) = 2;      % "mean" of connection-length between neurons
conn.lambda(II) = 2;      % "mean" of connection-length between neurons
		      
conn.rescale = 1;     % flag (meaningful only for static synapses):
                      %  0 ... use A parameters as they are
                      %  1 ... rescale by A = A * r_inf * u_inf
		      
conn.constW   = 0;    % flag: 0 ... sum of weights not normalized
                      %       1 ... sum of weights normaized to Asum (see below)
				      				      
conn.Wsum(EE) = +750; % sum of EE synapes weights (A) is normailzed to this value 
conn.Wsum(IE) = +150; % sum of IE synapes weights (A) is normailzed to this value 
conn.Wsum(EI) = -550; % sum of EI synapes weights (A) is normailzed to this value     
conn.Wsum(II) = -65;  % sum of II synapes weights (A) is normailzed to this value 

conn.C(EE)    = 0.3; 
conn.C(IE)    = 0.2;
conn.C(EI)    = 0.4;
conn.C(II)    = 0.1;

conn.Synapse = syn;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


nmc.def.pool = pool;
nmc.def.conn = conn;

