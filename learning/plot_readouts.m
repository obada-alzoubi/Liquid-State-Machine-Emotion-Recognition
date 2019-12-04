function besti = plot_readouts(readout,Rin,Sin,R2X,idx);
%
% PLOT_READOUTS plot target functions and outputs of readouts.
%
% SYNTAX
%
%  PLOT_READOUTS(F,R,S)
%  PLOT_READOUTS(F,R,S,R2X)
%  PLOT_READOUTS(F,R,S,R2X,I)
%
% DESCRIPTION
%
% PLOT_READOUTS(F,R,S) plots the targets and the outputs (if the
%   readouts F are trained) associated with the readouts F for the
%   given response (or states) R and stimuli S.
%
%   F ist a cell array of EXTERNAL_READOUT objects
%  
%   R is a struct array of responses or states as returned by
%     COLLECT_SR_DATA or RESPONSE2STATE.
%
%   S is the corresponding struct array of stimuli which caused R
%
% PLOT_READOUTS(F,R,S,R2X) is like PLOT_READOUTS(F,R,S) but you can
%   transform the responses R "on the fly" to states. R2X is a cell
%   array where R2X{1} is the name of the function to apply and
%   R2X{2:end} are the additional arguments for the function R2X{1}.
%
% PLOT_READOUTS(F,R,S,R2X,I) is like PLOT_READOUTS(F,R,S,R2X) but you
%   can specify the indices of stimuli to plot.
%
%
% SEE ALSO
%
%  COLLECT_SR_DATA, EXTERNAL_READOUT, TRAIN_READOUTS, RESPONSE2STATES
%
  
if nargin < 4, R2X = []; end
if nargin < 5, idx = []; end

DOCC = 0;

if isempty(R2X)
  R2X = { 'spikes2exp' };
end

clf reset;
nInputs   = length(Sin(1).channel);
nReadouts = length(readout);

if isempty(idx)
  idx=1:length(Rin);
end

maxperf = -Inf;
besti   = -1;
for i=idx
  clf reset;
  
  if isfield(Rin(1),'X')
    t=Rin(i).t;
    X=Rin(i).X;
  else
    s=feval(R2X{1},Rin(i),Sin(i),R2X{2:end});
    t=s.t;
    X=s.X;
  end
  %
  % plot the input
  %
  subplot(nReadouts+1,1,1);
  plot_channels(Sin(i).channel);
  set(gca,'XLim',[0 max(t)],'XTick',[],'Ylim',[0.5 nInputs+0.5]);
  title(sprintf('input %i',i));

  y = zeros(nReadouts,length(t));
  YL = [Inf -Inf];
  for f=1:nReadouts
    %    
    % calculate target function
    %
    y(f,:) = target_values(get(readout{f},'targetFunction'),Sin(i),t)';
    i_undef=find(isnan(y(f,:)));
    i_def=find(~isnan(y(f,:)));
    
    v=apply(readout{f},X)';
    
    subplot(nReadouts+1,1,f+1); cla reset;
    desc=get(readout{f},'description');
    if ~isempty(v)
      plot(t,y(f,:),'r.--',t(i_undef),mean(y(f,i_def))*ones(1,length(i_undef)),'g.',t,v,'bo-');
    else
      plot(t,y(f,:),'r.--',t(i_undef),mean(y(f,i_def))*ones(1,length(i_undef)),'g.');
    end
    if abs(min(y(f,i_def))-max(y(f,i_def))) > 1e-6
      set(gca,'Ylim',[min(y(f,i_def)) max(y(f,i_def))]);
    else
      axis tight;
    end
    yl=get(gca,'Ylim');
    YL(1)=min(YL(1),yl(1));
    YL(2)=max(YL(2),yl(2));
    set(gca,'Xlim',[0 max(t)]);
    if ~isempty(v)
      mae=mean(abs(y(f,i_def)-v(i_def)));
      mse=mean((y(f,i_def)-v(i_def)).^2);
      cc=corr_coef(y(f,i_def),v(i_def));
      perf(f) = cc;
      title(sprintf('%s (mae=%5.3g, mse=%5.3g, cc=%5.3g)',desc,mae,mse,cc),'Interpreter','none');
    else
      title(sprintf('%s (no output yet)',desc));
    end
    if f==nReadouts
      xlabel('time [sec]');
    else
      set(gca,'XTick',[]);
    end
  end
  if DOCC
    MSE=zeros(nReadouts);
    for fi=1:nReadouts
      for fj=1:nReadouts
	i_def=find(~isnan(y(fj,:)) & ~isnan(y(fi,:)));
	CC(fi,fj)=(corr_coef(y(fi,i_def),y(fj,i_def)));
	[kdummy,ddummy,MSE(fi,fj)]=linreg(y(fi,i_def),y(fj,i_def));
      end
    end
    CC
    MSE
    if ~isempty(v)
      if min(perf) > maxperf
	maxperf = min(perf);
	besti = i;
	fprintf('*** %i: %g \n',i,maxperf);
	besti
	drawnow; pause(0.3);
      end
    end
  end
  anykey;
end 
