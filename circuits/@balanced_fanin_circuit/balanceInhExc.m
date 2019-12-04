function nmc = balanceInhExc(nmc, p, Kfnc, argExcOrInh, f0)
% balanceInhExc Balance inhibition and excitation
%
% Syntax
%
%    nmc = balanceInhExc(nmc, p, Kfnc, EXCINH, f0);
%
%  Description
%  
%    nmc = balanceInhExc(nmc, p, Kfnc) scales the weights of the
%      inhibitory synapses onto a neuron in pool p such that is
%      counterbalances the excitatory input. Kfnc is a cell array
%      which specifies a distribution to draw the ratio INH/EXC from
%      (default: { @unirnd, 0.99, 1.0 }). Kfnc{1} is a function handle
%      to a random nuber generating function K{2:n} are parameters for
%      this function. The function specified by Kfnc{1} must also
%      accept the parameters m and n as last arguments to specify the
%      size of the matrix of random numbers to generate.
%
%  Algorithm
%
%    read the code
%
%  See also
%
%    balanceExcThresh
%
  
  
  if nargin < 2, p=1; end
  if nargin < 3, Kfnc= { @unirnd , 0.9, 1.1 }; end
  if nargin < 4, argExcOrInh = 'excinh'; end
  if nargin < 5, f0=20; end
  
  global_definitions

  
  pool = get(nmc, 'pool');
  
  type = csim('get',pool(p).neuronIdx,'type');
  
  excIdx = pool(p).neuronIdx(type == EXC);
  inhIdx = pool(p).neuronIdx(type == INH);

  switch argExcOrInh
   case 'exc'
    idxToBalance = [ excIdx ];
   case 'inh'
    idxToBalance = [ inhIdx ];
   case 'excinh'
    idxToBalance = [ excIdx inhIdx ];
   otherwise
    error('Unknown ExcOrInh value!');
  end
  
  nIdx = length(idxToBalance);
  
  if iscell(Kfnc)
    K=feval(Kfnc{:},1,nIdx);
  elseif isnumeric(Kfnc)
    K=Kfnc*ones(1,nIdx);
  end

  verbose(0,'balancing: inhibitory / excitatory = %.3g +/- %.3g  0%%',mean(K),std(K));

  for i=1:nIdx
    
    verbose(0,'\b\b\b\b%3i%%',round(100*i/nIdx));
    [inSyn,outSyn]=csim('get',idxToBalance(i),'connections');

    % find presynaptic neurons
    preIdx   = zeros(1,length(inSyn));
    w        = zeros(1,length(inSyn));
    tau_s    = zeros(1,length(inSyn));
    u0       = ones(1,length(inSyn));
    r0       = ones(1,length(inSyn));
    for s=1:length(inSyn)
      % get synaptic parameters
      synpar=csim('get',inSyn(s));

      w(s)     = synpar.W;
      tau_s(s) = synpar.tau;
      
      if isfield(synpar,'U')
        u0(s) = synpar.U ./ (1 - (1-synpar.U) .* exp(-1./(f0*synpar.F)) );
        r0(s) = (1 - exp(-1./(f0*synpar.D))) ./ (1 - (1-synpar.u0) .* exp(-1./(f0*synpar.D)) );
      end
    
    end

    % get type of neurons
    preInhIdx = find(w<0);
    preExcIdx = find(w>0);

    % calculate synaptic efficacy
    eff=u0.*r0.*w.*tau_s;
    
    % total excitatory input
    effE=abs(sum(eff(preExcIdx)));
    
    % total inhibitory input
    effI=abs(sum(eff(preInhIdx)));

    % adjust inhibition
    w(preInhIdx) = K(i)*effE*w(preInhIdx)/effI;
    
    % plug values back
    for s=1:length(inSyn)
      csim('set',inSyn(s),'W',w(s));
    end
    
  end
  
  verbose(0,'\b\b\b\b. Done.\n');
  