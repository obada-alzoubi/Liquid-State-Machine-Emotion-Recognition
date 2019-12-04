function efbinfo = efb(nmc, maxorder)

% EFB Counts the number of excitatory feedback loops
%
%  Syntax
%
%    efbinfo = efb(nmc, maxorder)
%
%  Description
%
%    EXPERIMENTAL !!!
%
%  Author
%
%    Christian Naeger, naeger@igi.tu-graz.ac.at

global_definitions;


for p = 1:length(nmc.pool)
  
  fprintf('Pool %i: ', p);
  
  efbinfo.pool(p).efb = struct([]);
  efbinfo.pool(p).nEXC = 0;
  efbinfo.pool(p).frac_EXC = 0;
  efbinfo.pool(p).nconnEE =  0;
  efbinfo.pool(p).p_connEE = 0;
  efbinfo.pool(p).nloops = [];
  efbinfo.pool(p).p_efb = [];
  
  nneuron = 0;
  nConnEE = 0;
  nEXC = 0;
  
  for order = 1:maxorder
    efbinfo.pool(p).nloops(order) = 0;
  end
  
  for ni = 1:length(nmc.pool(p).neuronIdx)
    
    fprintf('%i ', ni);
    
    idx = nmc.pool(p).neuronIdx(ni);
    
    nneuron = nneuron+1;
    
    type = csim('get', idx, 'type');
    
    if type == EXC
      
      nEXC = nEXC + 1;
      
      [pre, post] = csim('get', idx, 'connections');
      
      for s = 1:length(post)
	[preN, postN] = csim('get', post(s), 'connections');
	if csim('get', postN, 'type') == EXC
	  nConnEE = nConnEE +1;
	end
      end
      
    
      for order = 1:maxorder
	efbinfo.pool(p).efb(order).neuron{ni} = bfs(nmc, idx, idx, order+1, EXC);
	efbinfo.pool(p).nloops(order) = efbinfo.pool(p).nloops(order) + size(efbinfo.pool(p).efb(order).neuron{ni}, 1);
      end
      
    end
    
  end
  
  efbinfo.pool(p).nEXC = nEXC;
  efbinfo.pool(p).frac_EXC = nEXC / nneuron;
  efbinfo.pool(p).nconnEE = nConnEE;
  efbinfo.pool(p).p_connEE = nConnEE / (nEXC * (nEXC-1));

  for order = 1:maxorder
    efbinfo.pool(p).p_efb(order) = efbinfo.pool(p).nloops(order) / prod(nEXC-order:nEXC);
    efbinfo.pool(p).nloops(order) = efbinfo.pool(p).nloops(order) / (order+1);
    efbinfo.pool(p).p_efb_connEE(order) = efbinfo.pool(p).p_efb(order) / (efbinfo.pool(p).p_connEE .^ order);
  end
  
  fprintf('\n');
  
end



