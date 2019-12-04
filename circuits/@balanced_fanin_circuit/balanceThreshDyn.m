function [nmc, Kmean, Ksum, Kmax] = balanceThreshDyn(nmc, p, Kfnc, SynType)

  if nargin < 2, p=1; end
  if nargin < 3, Kfnc={ @unirnd, 10, 20 }; end
  if nargin < 4, SynType = EXC; end


  global_definitions

  pool = get(nmc, 'pool');
  postIdx  = [pool(p).neuronIdx];
  nIdx = length(postIdx);

  switch pool(p).type
   case {'LifNeuron','CbNeuronSt','CbNeuron','cACNeuron','bNACNeuron','dNACNeuron'}
    Apeak = inline('tau_s./(tau_m-tau_s).*((tau_s./tau_m).^(tau_s./(tau_m-tau_s))-(tau_s./tau_m).^(tau_m./(tau_m-tau_s)))');
   otherwise
    fprintf('Can not handle %s neurons! Command ignored.',pool(p).type);
    return;
  end

  if iscell(Kfnc)
    K=feval(Kfnc{:},1,nIdx);
  elseif isnumeric(Kfnc)
    K=Kfnc*ones(1,nIdx);
  end

  for i=1:nIdx
    
    [inSyn,outSyn]=csim('get',postIdx(i),'connections');

    % only 'DynamicSpikingSynapse' are used

    clear inSynDyn
    for inSynIdx = 1:length(inSyn)
       inSynParams = csim('get',inSyn(inSynIdx));
       inSynDyn(inSynIdx) = strcmp('DynamicSpikingSynapse',inSynParams.className);
    end


    inSyn = inSyn(inSynDyn);

    if ~isempty(inSyn)
      % read parameters

      Vthresh = csim('get',postIdx(i),'Vthresh');
      Rm = csim('get',postIdx(i),'Rm');
      Cm = csim('get',postIdx(i),'Cm');
      tau_m = Rm.*Cm;

      % find presynaptic neurons
      preIdx = zeros(1,length(inSyn));
      for s=1:length(inSyn)
        [preIdx(s),dummy]=csim('get',inSyn(s),'connections');
        preType(s)=csim('get',preIdx(s),'type');
        w(s)=csim('get',inSyn(s),'W');
        u0(s)=csim('get',inSyn(s),'u0');
        tau_s(s)=csim('get',inSyn(s),'tau');
      end

      % get type of neurons
      synIdx = find(preType==SynType);

      % calculate the peak of the PSP of one Synapse

      A=Rm*w.*u0.*Apeak(tau_m,tau_s);
      sgnA = sign(sum(A));
      A = abs(A);

      % average PSP amplitued
      meanPSP=mean(A(synIdx));
      sumPSP=sum(A(synIdx));
      maxPSP=max(A(synIdx));
      k = K(i)/meanPSP*Vthresh;

      % scale w such that the average PSP amplitude is (1/k)-th of Vthresh
%      w(synIdx) = w(synIdx)*k*sgnA;
      w(synIdx) = w(synIdx)*k;
      for s=1:length(inSyn)
        csim('set',inSyn(s),'W',w(s));
      end

      sumPSP = k*sumPSP;
      meanPSP = k*meanPSP;
      maxPSP = k*maxPSP;

      if ( sumPSP < Vthresh )
        fprintf('* % 3i: meanPSP/Vthresh = %5.3g/%5.3g = %5.3g, sumPSP/Vthresh = %5.3g/%5.3g = %5.3g\n',...
                i,meanPSP,Vthresh,meanPSP/Vthresh,sumPSP,Vthresh,sumPSP/Vthresh);
      end

      Kmean(i) = meanPSP/Vthresh;
      Ksum(i) = sumPSP/Vthresh;
      Kmax(i) = maxPSP/Vthresh;
    else
      fprintf('* % 3i: no dynamic input synapses found!\n',i);

      Kmean(i) = NaN;
      Ksum(i) = NaN;
      Kmax(i) = NaN;
    end
  end

