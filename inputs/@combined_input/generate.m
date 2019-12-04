function S=generate(this,argTstim,varargin)

if nargin < 2, argTstim = -1; end

S.channel = struct([]);

for i=1:length(this.inputs)
  s=generate(this.inputs{i},argTstim,varargin{:});
  if i==1
    S.channel = s.channel;
  else
    S.channel = [S.channel(:); s.channel(:)];  
  end
  fn=fieldnames(s.info);
  for j=1:length(fn)
    eval(['S.info(i).' fn{j} ' = s.info.' fn{j} ';']);
  end
  S.info(i).channels=length(S.channel(:))-length(s.channel)+1:length(S.channel);
  S.info(i).input_class=class(this.inputs{i});
  S.info(1).Tstim = max([S.info(:).Tstim]);
end
