function xy = response2states(Rin,Sin,sampling,filter,channels,pm) 

if nargin < 1, error('Response not specified!'); end
if nargin < 2, Sin = []; end
if nargin < 3, sampling = []; end
if nargin < 4, filter = []; end
if nargin < 5, channels = []; end
if nargin < 6, pm = 0; end
  
if isempty(sampling), sampling = '[0:0.025:Tsim]'; end
if isempty(filter), filter={ 'spikes2exp' 0.5 }; end


if ~isempty(Sin)
  if length(Sin) ~= length(Rin)
    error('number of stimuli not equal number of responses!');
  end
end

if ischar(sampling)
  at_times = [];
  at_t_fnc = inline(lower(sampling),'at_times','tmax','tsim','tstim','tstimulus');
else
  at_times = sampling;
  at_t_fnc = inline('at_times','at_times','tmax','tsim','tstim','tstimulus');
end

%
% loop over all S/R pairs
%
if ~can_run_parallel(pm)

  verbose(0,'calculating states (%i stimuli, filter=%s):   0%%',length(Rin),filter{1});
  
  [xy(1:length(Rin)).X] = deal([]);
  [xy(1:length(Rin)).t] = deal([]);

  if isempty(channels)
  end
  
  if ~isempty(Sin)
    for i=1:length(Rin)
      % output some progressinfo
      if rem(i,ceil(length(Rin)/50))==0
	verbose(0,'\b\b\b\b%3i%%',round(100*i/length(Rin)));
      end
      at_t=feval(at_t_fnc,at_times,Rin(i).Tsim,Rin(i).Tsim,Sin(i).info(1).Tstim,Sin(i).info(1).Tstim);
      xy(i).t = at_t(:); 
      if isfield(Rin(i),'spiketimes')
        xy(i).X = feval(filter{1},Rin(i),xy(i).t,filter{2:end});
      else
        xy(i).X = feval(filter{1},Rin(i).channel,xy(i).t,filter{2:end});
      end      
    end
  else
    for i=1:length(Rin)
      % output some progressinfo
      if rem(i,ceil(length(Rin)/50))==0
	verbose(0,'\b\b\b\b%3i%%',round(100*i/length(Rin)));
      end
      at_t=feval(at_t_fnc,at_times,Rin(i).Tsim,Rin(i).Tsim,NaN,NaN);
      xy(i).t = at_t(:); 
      if  isfield(Rin(i),'spiketimes')
        xy(i).X = feval(filter{1},Rin(i),xy(i).t,filter{2:end});
      else
        xy(i).X = feval(filter{1},Rin(i).channel,xy(i).t,filter{2:end});
      end
    end
  end 
  verbose(0,'\b\b\b\b\b\b. Done.\n');

else
  %
  % Run it parallel with 'blockSize' stimulations per block.
  % We choose 'blockSize' such that there are roughly 
  % 4 * #CPUs blocks to achieve a reasonable graining.
  %
  N=length(Rin);
  [nBlocks,blockSize,nCPUs]=blocksize(N);
  
  verbose(0,'calculating states (%i stimuli, filtertype=%s) in PARALLEL (on %i CPUs, %i blocks, size %i) ...\n',...
      length(sr),filter_type,nCPUs,nBlocks,blockSize);

  coll_fun=pmfun;
  coll_fun.expr    = 'd = response2states(Rin,Sin,sampling,filter,channels,0);'
  coll_fun.argin   = { 'Rin' 'Sin' };
  coll_fun.datain  = { 'GETBLOC(1)'  'GETBLOC(2)'};
  coll_fun.argout  = { 'd' };
  coll_fun.dataout = { 'SETBLOC(1)' };
  coll_fun.comarg  = {  'sampling' 'filter' 'channels' 'pm' };
  coll_fun.comdata = {   sampling   filter   channels   pm  };
  coll_fun.prefun  = 'rehash; PLOTTING_LEVEL=0; VERBOSE_LEVEL=1;';
  
  inds=createinds(Rin,[1 blockSize]);

  coll_fun.blocks = pmblock('src',[inds inds],'dst',inds);

  [err,xy] = dispatch(coll_fun,0,{ Rin Sin },[],[],'gui',0,'logfile','log.sr2x');
  
end
