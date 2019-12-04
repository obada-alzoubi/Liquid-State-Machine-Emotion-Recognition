function [readout, perf_train, perf_test] = train_readouts(readout,Xtrain,Strain,Xtest,Stest,pm)

if nargin < 3, error('Readout and traindata not specified!'); end
if nargin < 4, Xtest  = []; end
if nargin < 5, Stest  = []; end
if nargin < 6, pm     = 0;  end


if ~iscell(readout)
  readout = { readout };
end


if ~can_run_parallel(pm)
  for r=1:length(readout)
    verbose(0,'start training readout ``%s''''\n',get(readout{r},'description'));
    [readout{r},mae0,mse0,cc0,score0]=train(readout{r},Strain,'precalc_states',Xtrain);
    verbose(0,'train performance: cc=%g, mae=%g, mse=%g, score=%g',cc0,mae0,mse0,score0);
    perf_train(r).cc=cc0; perf_train(r).mae=mae0; perf_train(r).mse=mse0; perf_train(r).score=score0;

    if ~isempty(Xtest)
      verbose(0,' test performance ...');
      [mae1,mse1,cc1,score1]=performance(readout{r},Stest,'precalc_states',Xtest);
      verbose(0,'\b\b\b\b: cc=%g, mae=%g, mse=%g, score=%g',cc1,mae1,mse1,score1);
      perf_test(r).cc=cc1; perf_test(r).mae=mae1; perf_test(r).mse=mse1; perf_test(r).score=score1;
    else
      perf_test(r).cc = []; perf_test(r).mae = []; perf_test(r).mse= []; perf_test(r).score = [];
    end
    verbose(0,'\n');
  end
else
  N=length(readout);
  [nBlocks,blockSize,nCPUs]=blocksize(N);

  verbose(0,'training %i readouts in PARALLEL (on %i CPUs, %i blocks, size %i) ...\n',...
      N,nCPUs,nBlocks,blockSize);

  save trpm_common.mat readout blockSize Xtrain Strain Xtest Stest

  coll_fun=pmfun;
  coll_fun.expr    = [ ...
	               'ri=[i:i+blockSize-1];' ...
		       '[R, ptrain, ptest]=train_readouts(readout(ri),Xtrain,Strain,Xtest,Stest,0);'...
		     ];
  coll_fun.argin   = { 'i' };
  coll_fun.datain  = { 'GETBLOC(1)' };
  coll_fun.argout  = { 'ptrain' 'ptest'};
  coll_fun.dataout = { 'SETBLOC(1)' 'SETBLOC(2)'};
  coll_fun.comarg  = {  };
  coll_fun.comdata = {  };
  coll_fun.prefun  = 'rehash; load trpm_common.mat; PLOTTING_LEVEL=0; VERBOSE_LEVEL=1;';

  startIndex = 1:blockSize:N;
  indsi1=createinds(startIndex,[1 1]);
  perf_train = zeros(size(readout));
  indso1 = createinds(perf_train,[1 blockSize]);
  perf_test = zeros(size(readout));
  indso2 =createinds(perf_test,[1 blockSize]);

  coll_fun.blocks = pmblock('src',[indsi1],'dst',[indso1 indso2]);

  [err,perf_train, perf_test] = dispatch(coll_fun,0,{ startIndex },[],[],'gui',0,'logfile','log.trpm');

  delete trpm_common.mat

end

