function [] = plot_depression(R)

dt = 2e-3;

%
% get channels and it neuron indices
%

channel =[R.R{1}.channel R.R{1}.channel];

neuronIdx = [];
for nP = 1:length(R.R)
   neuronIdx = [neuronIdx get(R.C.circuit,'pool',{nP},'neuronIdx')];
end


%
% plot traces
%

for nR = 1:length(R.R)
   subplot(length(R.R),1,nR)

   Tsim = R.R{nR}.Tsim;

   % get neuron indices of this pool

   PoolNeuronsIdx = find([R.C.circuit_info.neuron.nPool]==nR);

   for nNeuron = 1:length(PoolNeuronsIdx)
      sIdx = R.C.circuit_info.neuron(PoolNeuronsIdx(nNeuron)).inSynapse;
      preNIdx = [R.C.circuit_info.synapse(sIdx).pre];

      TraceGes = zeros(1,floor(Tsim/dt));
      for nTr = 1:length(sIdx)
         idx = find(neuronIdx==preNIdx(nTr));

	 W = abs(R.C.circuit_info.synapse(sIdx(nTr)).W);
	 U = R.C.circuit_info.synapse(sIdx(nTr)).U;
	 D = R.C.circuit_info.synapse(sIdx(nTr)).D;
	 F = R.C.circuit_info.synapse(sIdx(nTr)).F;
	 u0 = R.C.circuit_info.synapse(sIdx(nTr)).u0;
	 r0 = R.C.circuit_info.synapse(sIdx(nTr)).r0;

	 ST = [channel(idx).data Tsim];
	 ST_bin = floor(ST/dt);

	 Trace = ones(1,ST_bin(1))*W*u0*r0;

	 for nST = 2:length(ST)
	    isi = [1:(ST_bin(nST)-ST_bin(nST-1))]*dt;

    	    r = 1 + (r0*(1-u0)-1)*exp(-isi/D);
            u = U + u0*(1-U)*exp(-isi/F);

	    Trace = [Trace W*u.*r];

	    u0 = u(end);
	    r0 = r(end);
	 end
         TraceGes = Trace + TraceGes;

      end

      % normalize to initial efficacy
      TraceGes = TraceGes/TraceGes(1);

      TraceMatrix(nNeuron,:) = TraceGes;
   end

   imagesc(flipdim(TraceMatrix,1))
   
   colorbar

   set(gca,'xticklabel',get(gca,'xtick')*dt)
   set(gca,'yticklabel',nNeuron-get(gca,'ytick'))

   name = get(R.C.template,'name');
   title(sprintf('''%s'' synaptic efficacy; Pool %i',name,nR),'fontweight','bold')
   ylabel('time [sec]')
   ylabel('neuron index')
end
