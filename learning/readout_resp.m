function resp = readout_resp(readout,Rin,Sin,R2X,idx);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desc		- Returns the readout response to a stimulus response pair.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File		- readout_resp.m
% Author	- Prashant Joshi ( joshi@igi.tugraz.at )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
if nargin < 4, R2X = []; end
if nargin < 5, idx = []; end


if isempty(R2X)
  R2X = { 'spikes2exp' };
end

nInputs   = length(Sin(1).channel);
nReadouts = length(readout);

if isempty(idx)
  idx=1:length(Rin);
end

maxperf = -Inf;
besti   = -1;
for i=idx
  
  if isfield(Rin(1),'X')
    t=Rin(i).t;
    X=Rin(i).X;
  else
    s=feval(R2X{1},Rin(i),Sin(i),R2X{2:end});
    t=s.t;
    X=s.X;
  end
y = zeros(nReadouts,length(t));

for f=1:nReadouts
    	% calculate target function
    	y(f,:)  = target_values(get(readout{f},'targetFunction'),Sin(i),t)';
    	i_undef = find(isnan(y(f,:)));
    	i_def   = find(~isnan(y(f,:)));
    	v       = apply(readout{f},X)';
	resp.readout(f).val = v;
end
end;
