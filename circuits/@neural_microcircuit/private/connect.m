function synapseIdx = connect(postIdx, preIdx, type, sh, synpar, constw, wsum, rescale)

% CONNECT Actually create synapses
%
%  Syntax
%
%    synapseIdx = connect(postIdx, preIdx, type, sh, synpar, constw, wsum, rescale)
%
%  Description
%
%    Actually create the synapses (csim create), set the parameters (csim set) and connect them with
%    the neurons (csim connect). Internal function: called only by add_conn.m
%
%  Author
%
%    Christian Naeger, naeger@igi.tu-graz.ac.at


global_definitions



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% check parameters
%

m = length(postIdx);
n = length(preIdx);

if m ~= n
  fprintf('neural_mircrocircuits connect: postIdx (%i) and preIdx(%i) must be the same. \n', m, n);
  error('ABORTING');
end

if m == 0 
  % no synapses at all ...
  synapseIdx = [];
  return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% connect pre- and postsynaptic neurons via synapses with random parameters 
%

DYNSYN  = ~isempty(strfind(type,'Dynamic'));


if synpar.W > 0
  synpar.W = sign(synpar.W) * bnd_gammarnd(abs(synpar.W), sh(1), abs(6*synpar.W), 1, m, 'exz A');
else
  synpar.W = sign(synpar.W) * bnd_gammarnd(abs(synpar.W), sh(1), abs(6*synpar.W), 1, m, 'inh A');
end

synpar.delay = bnd_normrnd(synpar.delay, sh(3), 0, abs(12*synpar.delay), 1, m, 'delay');

synpar.U = bnd_normrnd(synpar.U, sh(2), 0.05, 0.95, 1, m, 'U');
synpar.D = bnd_normrnd(synpar.D, sh(2), 5e-3,    5, 1, m, 'D');
synpar.F = bnd_normrnd(synpar.F, sh(2), 5e-3,    5, 1, m, 'F');

synpar.u0 = synpar.U ./ (1 - (1-synpar.U) .* exp(-1./(synpar.f0*synpar.F)) );
synpar.r0 = (1 - exp(-1./(synpar.f0*synpar.D))) ./ (1 - (1-synpar.u0) .* exp(-1./(synpar.f0*synpar.D)) );

if ~DYNSYN & rescale
  synpar.W = synpar.W .* synpar.u0 .* synpar.r0;
end

if constw
  synpar.W = synpar.W/sum(synpar.W) * wsum;
end

synapseIdx = csim('create', type, m);

csim('connect', postIdx, preIdx, synapseIdx);

sdesc = csim('get', synapseIdx(1));

fn = fieldnames(synpar);
fi = find(ismember(fn, sdesc.fields));

for i = 1:length(fi)
  para = eval(sprintf('synpar.%s', fn{fi(i)} ));
  csim('set', synapseIdx, fn{fi(i)}, para);
end

