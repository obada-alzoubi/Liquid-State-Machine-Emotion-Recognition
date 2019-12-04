function mc_info = get_additional_circuit_info(mc,CT);

% called by GENERATE
% stores some parameters of the generated circuit
%
% Author: Haeusler 08/14/03 (haeusler@igi.tu-graz.ac.at)


mc_info = [];


%
% get synapse parameter
%

preNIdx = [];
postNIdx = [];
sIdx = 0;
for nConn = 1:length(CT.conn)

   Idx = get(mc,'conn',{nConn},'synapseIdx');

   Syn_W =  csim('get',Idx,'W');
   Syn_U =  csim('get',Idx,'U');
   Syn_D =  csim('get',Idx,'D');
   Syn_F =  csim('get',Idx,'F');
   Syn_u0 =  csim('get',Idx,'u0');
   Syn_r0 =  csim('get',Idx,'r0');

   for i = 1:length(Idx)
      [preNIdx(end+1),postNIdx(end+1)] = csim('get',Idx(i),'connections');

      sIdx = sIdx + 1;
      mc_info.synapse(sIdx).nConn = nConn;
      mc_info.synapse(sIdx).pre = preNIdx(end);
      mc_info.synapse(sIdx).post = postNIdx(end);

      mc_info.synapse(sIdx).W  =  Syn_W(i);
      mc_info.synapse(sIdx).U  =  Syn_U(i);
      mc_info.synapse(sIdx).D  =  Syn_D(i);
      mc_info.synapse(sIdx).F  =  Syn_F(i);
      mc_info.synapse(sIdx).u0 = Syn_u0(i);
      mc_info.synapse(sIdx).r0 = Syn_r0(i);
   end
end


nNb = 0;
for nP = 1:length(CT.pool)

   nIdx = get(mc,'pool',{nP},'neuronIdx');

   for nN = 1:length(nIdx)
      in = find(postNIdx==nIdx(nN));
      out = find(preNIdx==nIdx(nN));

      nNb = nNb + 1;
      mc_info.neuron(nNb).nPool = nP;
      mc_info.neuron(nNb).inSynapse = in;
      mc_info.neuron(nNb).outSynapse = out;
   end
end