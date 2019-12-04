function [ cost_value, cost_flag ] = cost_function_mfr_stop(x);

ALL = -1;

fitparam = evalin('base','fitparam');
fn = fieldnames(fitparam);
for nfn = 1:length(fn)
   eval(sprintf('%s = fitparam.%s;',fn{nfn},fn{nfn}))
end


nX = 1;
cost_value = 0;
global csim_obj

for nC = 1:length(C)
   if length(C) > 1
	csim('destroy')

	% decode circuit parameters

        [C{nC},nX] = decode_syn_parameter(C{nC},x,nX,SynapsesToFit);

        % record from all liquid neurons
        C{nC}.OUTidx = -1; % ALL

        % generate circuit from smc template
        generate(C{nC});
   
        csim('set','dt',DT_SIM);
        csim('set','randSeed',12345);

   else
      i = strmatch('DynamicSpikingSynapse',{csim_obj.object.type},'exact') - 1;
      j = strmatch('StaticSpikingSynapse',{csim_obj.object.type},'exact') - 1;
      i = sort([i j])';

      for nSyn = 1:length(i)
         % check if no output synapse
         if find(csim_obj.src == i(nSyn))& ...
              ( ~isempty(find(SynapsesToFit==nSyn)) | SynapsesToFit == ALL )
	      switch csim_obj.object(i(nSyn)+1).type
		 case 'DynamicSpikingSynapse'
		    csim('set',uint32(i(nSyn)),'W',x(nX)); nX = nX + 1;

		    csim('set',uint32(i(nSyn)),'U',x(nX)); nX = nX + 1;
		    csim('set',uint32(i(nSyn)),'D',x(nX)); nX = nX + 1;
		    csim('set',uint32(i(nSyn)),'F',x(nX)); nX = nX + 1;
		 case 'StaticSpikingSynapse'
		    csim('set',uint32(i(nSyn)),'W',x(nX)); nX = nX + 1;
    	      end
           end
        end
   end

   for nS = 1:size(Sc,1)
      % add dummt channel if simulation input is empty
      if isempty(Sc{nS,nC}.channel)
         i = strmatch('AnalogInputNeuron',{csim_obj.object.type},'exact');
         AINidxC = uint32(i-1);
         input = [];
         input.idx = AINidxC(1);
	 input.spiking = 0;
	 input.data = [0.0 0.0];
	 input.dt = Tmax;
      else
         input = Sc{nS,nC}.channel;
      end

      % and simulate
      csim('reset')
      R = csim('simulate',Tmax,input);
      R{1}.data = abs(R{1}.data);
 

      for nCr = 1:length(criterion)
         switch criterion{nCr}
            case 'mfr'
               for i = 1:length(C{nC}.neuron)
                  ri = min(i,size(crit_par{nCr},1));
                  if ~isnan(crit_par{nCr}(ri,1))&~isnan(crit_par{nCr}(ri,2))
                     if ~isempty(R{2}.idx)
                        v = length(find(R{2}.idx==i)) - crit_par{nCr}(ri,1)*Tmax;
                     else
                        v = crit_par{nCr}(ri,1)*Tmax;
                     end 
                     cost_value = cost_value + v^2*crit_par{nCr}(ri,2) + ...
                                  sign(v)*mean(R{1}.data(i,:)); % for gd
                  end
               end
            case 'stop'
               if ~isempty(R{2}.idx)
                  for i = 1:length(C{nC}.neuron)
                     ri = min(i,size(crit_par{nCr},1));
                     if ~isnan(crit_par{nCr}(ri,1))&~isnan(crit_par{nCr}(ri,2))
                        if max(R{2}.times(find(R{2}.idx==i))) > crit_par{nCr}(ri,1)
                           cost_value = cost_value + crit_par{nCr}(ri,2); 
                        end
                     end
                  end
               end
            case 'anticorr'

               v = R{1}.data;
               m =  mean(v,2);
               v = v - repmat(m,1,size(v,2));

               for j = 1:size(crit_par{nCr},1)
                  k = sqrt( sum(v(crit_par{nCr}(j,1),:).^2) * sum(v(crit_par{nCr}(j,2),:).^2) );
                  if k==0;
                     w = crit_par{nCr}(j,3);
                  else
                     w = sum(v(crit_par{nCr}(j,1),:).*v(crit_par{nCr}(j,2),:))/k;
                  end
                  cost_value = cost_value + w * crit_par{nCr}(j,3); 
               end
         end
      end
   end
end

fprintf('cost_value: %g\n',cost_value)


cost_flag = 1;
