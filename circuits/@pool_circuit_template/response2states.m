function [STout]=response2states(this,Rin,method,varargin)
%RESPONSE2STATES   converts the pool circuit template response to states.
%   ST = RESPONSE2STATES(P,R,M) converts the pool circuit template
%   responses R under usage of the transformation function M to circuit
%   states ST. The circuit response R is an NS-by-NC cell array, where
%   NC is the number of pool circuit templates and NS is the number of
%   input stimuli. An element of the cell array contains a structure with
%   the responses of each circuit to each input stimuli and the fields
%
%	 'R'      ... spike response returned by CSIM('simulate',Tmax,I)
%	 'S'      ... stimulus, e.g. S1.
%	 'C'      ... circuit structure, e.g. C1
%
%   as returned by R = SIMULATE(P,C1,C2,...,S1,S2,...).
%
%   Possible transformation functions M are
%
%	 'mfr'    ... mean firing rate (default bin size 5 ms)
%        'mIsyn'  ... mean synaptic current (default bin size 5 ms)
%        'mGsyn'  ... mean synaptic conductance (default bin size 5 ms)
%        'mVm'    ... mean membrane potential (default bin size 5 ms)
%
%   The circuit state output argument ST is a cell array of structures with
%   the same size as R and the fields
%
%	 'data'   ... matrix of size ND-by-NT, where ND is the circuit
%		      state space dimension (number of output neurons) and
%		      NT is the number of sampling time points
%	 'info'   ... contains informations about the creation of the
%		      ciruit states. It is a structure with the fields
%
% 		       'method'   ... a struct with fields
%
%		  		       'name'    ... transform. func. M
%				       'dt_bin'  ... sampling time steps
%
%                      'stimulus' ... stimulus, e.g. S1.
%                      'circuit'  ... a struct with field
%
%				       'template' ... e.g. C1.TEMPLATE
%
%
%   See also POOL_CIRCUIT_TEMPLATE/GENERATE
%            POOL_CIRCUIT_TEMPLATE/PLOT
%	     POOL_CIRCUIT_TEMPLATE/POOL_CIRCUIT_TEMPLATE
%            POOL_CIRCUIT_TEMPLATE/ADJUST
%	     POOL_CIRCUIT_TEMPLATE/MODEL2STATES
%            POOL_CIRCUIT_TEMPLATE/STATES2MODEL
%	     POOL_CIRCUIT_TEMPLATE/VISUALIZE
%            POOL_CIRCUIT_TEMPLATE/SIMULATE
%
%   Author: Stefan Haeusler, 5/2003, haeusler@igi.tu-graz.ac.at

% convert input argument format to cell array

if nargin < 2
   error('Input argument pool circuit template responses ''R'' missing!');
elseif nargin < 3
   method = 'mfr';
end

if iscell(Rin)
   R = Rin;
else
   R{1,1} = Rin;
end

% check size

nCircuits = size(R,2);
nStimuli = size(R,1);

% Tmax

Tmax = 0;
for nS = 1:nStimuli
   Tmax = max(Tmax,R{nS,1}.S.info.Tstim);
end


for nC = 1:nCircuits
   for nS = 1:nStimuli

      switch method
         case 'mVm'
	    if nargin > 3
	       dt_bin = varargin{1};
	    else
               dt_bin = 5e-3;
	    end


            ST{nS,nC}.data = []; % default value
            for i = 1:length(R{nS,nC}.R)
  	       if all(strcmp({R{nS,nC}.R{i}.channel.fieldName},'Vm'))
                  ST{nS,nC}.data(end+1,:) = mean(vertcat(R{nS,nC}.R{i}.channel.data),1);
	       end
            end

            ST{nS,nC}.info.method.name = 'mVm';
            ST{nS,nC}.info.method.label = 'Mean membrane potential [V]';
            ST{nS,nC}.info.method.dt_bin = dt_bin;

            ST{nS,nC}.info.stimulus.S = R{nS,nC}.S;
            ST{nS,nC}.info.circuit.template = R{nS,nC}.C.template;

         case 'mIsyn'
	    if nargin > 3
	       dt_bin = varargin{1};
	    else
               dt_bin = 5e-3;
	    end


            ST{nS,nC}.data = []; % default value
            for i = 1:length(R{nS,nC}.R)
  	       if all(strcmp({R{nS,nC}.R{i}.channel.fieldName},'Isyn'))
                  ST{nS,nC}.data(end+1,:) = mean(vertcat(R{nS,nC}.R{i}.channel.data),1);
	       end
            end

            ST{nS,nC}.info.method.name = 'mIsyn';
            ST{nS,nC}.info.method.label = 'Mean synaptic current [A]';
            ST{nS,nC}.info.method.dt_bin = dt_bin;

            ST{nS,nC}.info.stimulus.S = R{nS,nC}.S;
            ST{nS,nC}.info.circuit.template = R{nS,nC}.C.template;

         case 'mGsyn'
	    if nargin > 3
	       dt_bin = varargin{1};
	    else
               dt_bin = 5e-3;
	    end

            ST{nS,nC}.data = []; % default value
            for i = 1:length(R{nS,nC}.R)
  	       if all(strcmp({R{nS,nC}.R{i}.channel.fieldName},'Gsyn'))
                  ST{nS,nC}.data(end+1,:) = mean(vertcat(R{nS,nC}.R{i}.channel.data),1);
	       end
            end

            ST{nS,nC}.info.method.name = 'mGsyn';
            ST{nS,nC}.info.method.label = 'Mean synaptic conductance [S]';
            ST{nS,nC}.info.method.dt_bin = dt_bin;

            ST{nS,nC}.info.stimulus.S = R{nS,nC}.S;
            ST{nS,nC}.info.circuit.template = R{nS,nC}.C.template;

         case 'mfr'
	    if nargin > 3
	       dt_bin = varargin{1};
	    else
               dt_bin = 5e-3;
	    end

%	    hist_bins = -dt_bin:dt_bin:Tmax-2*dt_bin;
	    hist_bins = dt_bin:dt_bin:Tmax;

            ST{nS,nC}.data = []; % default value
            for i = 1:length(R{nS,nC}.R)
	     if all([R{nS,nC}.R{i}.channel.spiking])
               if ~isempty([R{nS,nC}.R{i}.channel.data])
                   ST{nS,nC}.data(end+1,:) = histc([R{nS,nC}.R{i}.channel.data],hist_bins)/dt_bin/length(R{nS,nC}.R{i}.channel);
	       else
	           ST{nS,nC}.data(end+1,:) = zeros(1,length(hist_bins));
	       end
	     end
            end

            ST{nS,nC}.info.method.name = 'mfr';
            ST{nS,nC}.info.method.label = 'Mean firing rate [Hz]';
            ST{nS,nC}.info.method.dt_bin = dt_bin;

            ST{nS,nC}.info.stimulus.S = R{nS,nC}.S;
            ST{nS,nC}.info.circuit.template = R{nS,nC}.C.template;

         case 'lpf'
	    if nargin > 3
	       tau = varargin{1};
	    else
               tau = 10e-3;
	    end

	    if nargin > 4
	       dt_bin = varargin{2};
	    else
               dt_bin = 1e-3;
	    end

	    tau_bin  = tau/dt_bin;
	    lin_kern = exp(-[0:5*tau_bin]/tau_bin)/tau_bin;

	    hist_bins = dt_bin:dt_bin:Tmax;

            ST{nS,nC}.data = []; % default value
            for i = 1:length(R{nS,nC}.R)
	     if all([R{nS,nC}.R{i}.channel.spiking])
               if ~isempty([R{nS,nC}.R{i}.channel.data])
		   signal = histc([R{nS,nC}.R{i}.channel.data],hist_bins)/dt_bin/length(R{nS,nC}.R{i}.channel);
		   signal = conv(signal,lin_kern);
                   ST{nS,nC}.data(end+1,:) = signal(1:end-length(lin_kern)+1);
	       else
	           ST{nS,nC}.data(end+1,:) = zeros(1,length(hist_bins));
	       end
	     end
            end

            ST{nS,nC}.info.method.name = 'lpf';
            ST{nS,nC}.info.method.label = sprintf('lpf (tau %gs) mfr [Hz]',tau);
            ST{nS,nC}.info.method.dt_bin = dt_bin;
            ST{nS,nC}.info.method.tau = tau;

            ST{nS,nC}.info.stimulus.S = R{nS,nC}.S;
            ST{nS,nC}.info.circuit.template = R{nS,nC}.C.template;


         case 'window'
	    if nargin > 3
	       tau = varargin{1};
	    else
               tau = 10e-3;
	    end

	    if nargin > 4
	       dt_bin = varargin{2};
	    else
               dt_bin = 1e-3;
	    end

	    tau_bin  = tau/dt_bin;
	    lin_kern = ones(1,tau_bin)/tau_bin;

            ST{nS,nC}.data = []; % default value
	    for i = 1:length(R{nS,nC}.R)
	     if all([R{nS,nC}.R{i}.channel.spiking])
               if ~isempty([R{nS,nC}.R{i}.channel.data])
		   signal = histc([R{nS,nC}.R{i}.channel.data],hist_bins)/dt_bin/length(R{nS,nC}.R{i}.channel);
		   signal = conv(signal,lin_kern);
                   ST{nS,nC}.data(end+1,:) = signal(1:end-length(lin_kern)+1);
	       else
	           ST{nS,nC}.data(end+1,:) = zeros(1,length(hist_bins));
	       end
	     end
            end

            ST{nS,nC}.info.method.name = 'window';
            ST{nS,nC}.info.method.label = sprintf('window (%gs) filtered mfr [Hz]',tau);
            ST{nS,nC}.info.method.dt_bin = dt_bin;
            ST{nS,nC}.info.method.tau = tau;

            ST{nS,nC}.info.stimulus.S = R{nS,nC}.S;
            ST{nS,nC}.info.circuit.template = R{nS,nC}.C.template;


        otherwise
	   err_str = sprintf('Response to state transformation ''%s'' unknown!',method)
	   error(err_str)
     end
   end
end

% convert to output argument format

if iscell(Rin)
   STout = ST;
else
   STout = ST{1,1};
end



