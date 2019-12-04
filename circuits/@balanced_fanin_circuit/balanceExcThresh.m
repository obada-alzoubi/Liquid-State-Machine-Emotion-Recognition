function [nmc, Kmean, Ksum] = balanceExcThresh(nmc, p, Kfnc, f0)

  if nargin < 2, p=1; end
  if nargin < 3, Kfnc=[]; end
  if nargin < 4, f0 = []; end
  
  if isempty(Kfnc), Kfnc={ @unirnd, 1/10, 1/20 }; end
  if isempty(f0), f0=20; end
  
  global_definitions

  pool = get(nmc, 'pool');
  postIdx  = [pool(p).neuronIdx];
  nIdx = length(postIdx);
  
  switch pool(p).type
   case 'LifNeuron'
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

  verbose(0,'balancing: excitation / threshold = %.3g +/- %.3g  0%%',mean(K),std(K));

  for i=1:nIdx
        
    [inSyn,outSyn]=csim('get',postIdx(i),'connections');

    if ~isempty(inSyn)
      npar =  csim('get',postIdx(i));
    
      tau_m = npar.Rm*npar.Cm;
      
      % effective threshold
      theta = (npar.Vthresh - npar.Rm*npar.Iinject);
      
      % find presynaptic neurons
      w        = zeros(1,length(inSyn));
      tau_s    = zeros(1,length(inSyn));
      u0       = ones(1,length(inSyn));
      r0       = ones(1,length(inSyn));
      for s=1:length(inSyn)
        synpar=csim('get',inSyn(s));
        w(s)=synpar.W;
        tau_s(s)=synpar.tau;
        
        if isfield(synpar,'U')
          u0(s) = synpar.U ./ (1 - (1-synpar.U) .* exp(-1./(f0*synpar.F)) );
          r0(s) = (1 - exp(-1./(f0*synpar.D))) ./ (1 - (1-synpar.u0) .* exp(-1./(f0*synpar.D)) );
        end
        
      end
      
      % get type of neurons
      excIdx = find(w>0);
      
      % calculate the peak of the EPSP of one Synapse
      A=npar.Rm*u0.*r0.*w.*Apeak(tau_m,tau_s);
      
      % average EPSP amplitued
      meanEPSP=mean(A(excIdx));    
      sumEPSP=sum(A(excIdx));
      k = theta*K(i)/meanEPSP;

      % scale w such that the average exc. EPSP amplitude is K * theta
      w = w*k;
      
      % stuff weights back
      for s=1:length(inSyn)
        csim('set',inSyn(s),'W',w(s));
      end

      sumEPSP = k*sumEPSP;
      meanEPSP = k*meanEPSP;
      
      if ( sumEPSP < theta )  
        fprintf('* % 3i: meanEPSP/theta = %5.3g/%5.3g = %5.3g, sumEPSP/theta = %5.3g/%5.3g = %5.3g\n',...
                i,meanEPSP,theta,meanEPSP/theta,sumEPSP,theta,sumEPSP/theta);
      end
      
      Kmean(i) = meanEPSP/theta;
      Ksum(i) = sumEPSP/theta;
      
    end 
    
    verbose(0,'\b\b\b\b%3i%%',round(100*i/nIdx));

  end
  
  
  verbose(0,'\b\b\b\b. Done.\n');
  