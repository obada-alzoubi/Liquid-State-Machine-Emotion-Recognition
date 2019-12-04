function [n_nmc, ro_index] = transform_readout(nmc, ext_ro, analogfilter, ...
					       spikefilter)

% TRANSFORM_READOUT Transforms an external readout to an internal object
%
% Syntax
%
%    [n_nmc, ro_index] = transform_readout(nmc, ext_ro [,
%    analogfilter, spikefilter])
%
% Arguments
%
%      n_nmc        ...   New Neural-Microcircuit
%      ro_index     ...   Index of the readout object in CSIM
%      nmc          ...   Input Neural-Microcircuit
%      ext_ro       ...   External Readout Object
%      analogfilter ...   Parameters of analog filter object
%      spikefilter  ...   Parameters of spike filter object
%
% Description
%
%   This function transforms an external readout, which is trained
%   offline, to an internal CSIM-Readout object for online
%   validation. The function transforms all filter, preprocessor and
%   algorithm data trained offline to CSIM objects.
%   If the filter parameters are not specified, a Gaussian low-pass
%   filter kernel of length 3 (std_dev = 1.0) is used for analog filtering, and an
%   Exponential-decay Spike Filter with tau1=0.03 are used.
%
% Author
%
%   Michael Pfeiffer, pfeiffer@igi.tugraz.at


% Input preprocessing
if (nargin < 3) analogfilter = []; end;
if (nargin < 3) spikefilter = []; end;


if isempty(analogfilter)
  analogfilter={ 'GaussianAnalogFilter', 'nKernelLength', 3,'m_std_dev', ...
		 1.0 };
end;
if isempty(spikefilter)
%  spikefilter={{ 'ExpSpikeFilter', 'm_tau1', 0.03 } {}};
   spikefilter={ 'ExpSpikeFilter', 'm_tau1', 0.03 };
end;



% Create the readout object
% Unfortunately this does not work since add('pool') assumes
% that only neurons are added
%[n_nmc, ro_index] = add(nmc, 'Pool', 'type', 'Readout');
% ro_pool_idx = get(n_nmc, 'pool', 'neuronIdx');

ro_index = csim('create', 'Readout');

% Get the inputs for the readout
recorders = get(nmc, 'recorder');

% Connect them to the readout
nrinputs = 0;
for i = 1:length(recorders)
  rec = recorders(i);
  csim('connect', ro_index, rec.rec_idx, rec.Field);
  nrinputs = nrinputs + length(rec.rec_idx);
end

% ***************************
% Create filter objects
% ***************************
af = csim('create', analogfilter{1});
for i = 2:2:length(analogfilter)
  csim('set', af, analogfilter{i}, analogfilter{i+1});
end;
csim('connect', ro_index, af);


% Create spike-filter
sf = csim('create', spikefilter{1});
for i = 2:2:length(spikefilter)
  csim('set', sf, spikefilter{i}, spikefilter{i+1});
end;
% Create additional low-pass filter
%if ~isempty(spikefilter{2})
%  lpf = csim('create', spikefilter{2}{1});
%  for i = 2:2:length(spikefilter{2})
%    csim('set', lpf, spikefilter{2}{i}, spikefilter{2}{i+1});
%  end;
%  csim('connect', lpf, sf);
%end;

csim('connect', ro_index, sf);


% ***************************
% Create preprocessor objects
% ***************************

preprocess = get(ext_ro, 'preprocess');

% Create discretization preprocessor
epsilon = get(ext_ro, 'epsState');
if ( ~isempty(epsilon) )
  verbose(0,'discretizeing states (eps=%g) ...',epsilon);
  disc_pre = csim('create','DiscretizationPreprocessor');
  csim('import', disc_pre, [nrinputs, epsilon * ones(1, nrinputs)]);
  csim('connect', ro_index, disc_pre);
  verbose(0,'\b\b\b\b. Done.\n');
end

% Create PCA preprocessor
pcadimension = nrinputs;
if isfield(preprocess, 'P')
  P = preprocess.P;  % This is the PCA matrix
  if ~isempty(P) & ~isempty(this.Vpca) & this.Vpca <= 1 & this.Vpca ...
	>= 0
    verbose(0,'applying pca transformation ...');
    pca_pre = csim('create','PCAPreprocessor');
    pcadimension = size(P, 2);
    imp = [nrinputs pcadimension P(:)];
    csim('import', pca_pre, imp);
    csim('connect', ro_index, pca_pre);
    verbose(0,'\b\b\b\b. Keeping %i of %i dimensions.\n',pcadimension,nrinputs);
  end
end

% Create normalization preprocessor
if get(ext_ro, 'doNorm') & isfield(preprocess, 'meanx') & ...
      isfield(preprocess, 'stdx')
  if ~isempty(preprocess.meanx) & ~isempty(preprocess.stdx)
    verbose(0,'applying mean/std transformation ...');
    mstd_pre = csim('create','Mean_Std_Preprocessor');
    csim('import', mstd_pre, [pcadimension; preprocess.meanx(:); ...
		    preprocess.stdx(:)]);
    csim('connect', ro_index, mstd_pre);
    verbose(0,'\b\b\b\b. Done.\n');
  end
end

% Get scale of readout
if isfield(preprocess, 'a')
  a = preprocess.a;
  if ~isempty(a)
    csim('set', ro_index, 'range',a);
  end
end;
if isfield(preprocess, 'b')
  b = preprocess.b;
  if ~isempty(b)
    csim('set', ro_index, 'offset',b);
  end
end;





% ***************************
% Create algorithm objects
% ***************************

algorithm = get(ext_ro, 'algorithm');

% Export algorithm representation and connect it
verbose(0,'importing algorithm\n');
algo = csim('create',get(algorithm, 'name'));
alg_params = export(algorithm);
if ~isempty(alg_params)
  csim('import', algo, alg_params);
end;

csim('connect', ro_index, algo);
verbose(0,'\b\b\b\b. Done.\n');

% Set range of algorithm
range = get(algorithm, 'range');
if ~isempty(range)
  csim('set', algo, 'range_low', range(1));
  csim('set', algo, 'range_high', range(2));
end;



n_nmc = nmc;


% ********************************
% Check for invalid subset command
% ********************************
if ~strcmp(get(ext_ro, 'subset'), 'all')
  error('Cannot use subsets for online validation!\b');
end;






