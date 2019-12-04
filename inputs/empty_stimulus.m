function S=empty_stimulus(varargin)

  while length(varargin)>0
    
    switch lower(varargin{1}(1:3))
      
     case 'nch'
      d = varargin{2};
      varargin = varargin(3:end);
      
     case 'tst'
      T = varargin{2};
      varargin = varargin(3:end);

     otherwise
      error('unknown argument!');
      
    end 
  end
  
if isempty(d), error('nChannels undefined!'); end
if isempty(T), error('Tstim undefined!'); end

S.info(1).Tstim      = T;
S.channel(d).data    = [];
[S.channel(1:d).spiking] = deal(0);
[S.channel(1:d).dt]      = deal(1);

