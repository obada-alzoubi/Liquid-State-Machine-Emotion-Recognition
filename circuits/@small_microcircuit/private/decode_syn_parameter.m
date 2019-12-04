function [C,nX] = decode_syn_parameter(C,x,nX,SynapsesToFit);

ALL = -1;

for nSyn = 1:length(C.synapse)
   if ~isnan(C.synapse(nSyn).Post_n) & ...
     ( ~isempty(find(SynapsesToFit==nSyn)) | SynapsesToFit == ALL )
     switch C.synapse(nSyn).spec
         case 'DynamicSpikingSynapse'
            C.synapse(nSyn).A = x(nX)/C.Ascale; nX = nX + 1;

            C.synapse(nSyn).U = x(nX); nX = nX + 1;
            C.synapse(nSyn).D = x(nX); nX = nX + 1;
            C.synapse(nSyn).F = x(nX); nX = nX + 1;

         case 'StaticSpikingSynapse'
            C.synapse(nSyn).A = x(nX)/C.Ascale; nX = nX + 1;
      end
   end
end

