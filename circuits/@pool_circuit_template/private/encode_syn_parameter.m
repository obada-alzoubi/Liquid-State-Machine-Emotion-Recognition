function [xinit,xl,xu,xt] = encode_syn_parameter(C,SynapsesToFit);

SYN_MAX = 1e2;
ALL = -1;

xinit = []; xl = []; xu = []; xt = [];
nX = 1;
for nC = 1:length(C)
   for nSyn = 1:length(C{nC}.synapse)
      if ~isnan(C{nC}.synapse(nSyn).Post_n) & ...
         ( ~isempty(find(SynapsesToFit==nSyn)) | SynapsesToFit == ALL )
         switch C{nC}.synapse(nSyn).spec
            case 'DynamicSpikingSynapse'
               xinit(nX) = C{nC}.synapse(nSyn).A*C{nC}.Ascale;
	       xl(nX) = min(0,SYN_MAX*sign(xinit(nX)));
	       xu(nX) = max(0,SYN_MAX*sign(xinit(nX)));
	       xt(nX) = -1; nX = nX + 1;

               xinit(nX) = C{nC}.synapse(nSyn).U;
	       xl(nX) = 0; xu(nX) = 1; xt(nX) = -1; nX = nX + 1;

               xinit(nX) = C{nC}.synapse(nSyn).D;
	       xl(nX) = 0; xu(nX) = 3; xt(nX) = -1; nX = nX + 1;

               xinit(nX) = C{nC}.synapse(nSyn).F;
	       xl(nX) = 0; xu(nX) = 3; xt(nX) = -1; nX = nX + 1;

            case 'StaticSpikingSynapse'
               xinit(nX) = C{nC}.synapse(nSyn).A*C{nC}.Ascale;
	       xl(nX) = min(0,SYN_MAX*sign(xinit(nX)));
	       xu(nX) = max(0,SYN_MAX*sign(xinit(nX)));
	       xt(nX) = -1; nX = nX + 1;
         end
      end
   end
end

