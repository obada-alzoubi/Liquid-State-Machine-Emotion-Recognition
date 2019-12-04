function [W,B]=pdelta_batch(train,valid,param,validinter,dispinter,W0,PLOT)

if nargin < 4, validinter = []; end
if nargin < 5, dispinter = []; end
if nargin < 6, W0 = []; end
if nargin < 7, PLOT=0; end

if isempty(dispinter), dispinter = ceil(param.maxepoch/10); end
if isempty(validinter), validinter = min(dispinter,10); end
if isempty(PLOT), PLOT=0; end

if ~isfield(train,'xv'), train.xv = 1:length(train.Y); end
if ~isempty(valid)
  if ~isfield(valid,'xv'), valid.xv = 1:length(valid.Y); end
end

n=param.n;
rho=param.rho;
eps=param.eps;
eta0=param.eta;
mu=param.mu;
gamma0=param.gamma;
maxepoch=param.maxepoch;
max_err_inc=param.max_err_inc;
lr_dec=param.lr_dec;
lr_inc=param.lr_inc;
maxwu=param.maxwu;
eta = eta0;
gamma=gamma0;


[d,m]=size(train.X);
if ~isempty(valid)
  if size(valid.X,1) ~= d
    error('dimension of training and validation data must be equal!');
  end
end

if isempty(W0)
  W = 1-2*rand(d+1,n);
else
  W = W0;
end

muX    = mean(train.X,2);
sigmaX = std(train.X,1,2);
sigmaX(sigmaX==0) = 1;

X = train.X -  repmat(muX,[1 m]);
X = X ./ repmat(sigmaX,[1 m]);

X = [X; ones(1,m)];
d=d+1;

train.Z = X ./ repmat(sqrt(sum(X.^2)),[d 1]);

train.muX    = muX;
train.sigmaX = sigmaX;
train.meanY  = mean(train.Y);
train.nY     = norm(train.Y-train.meanY);
train.avgerr = mean(abs(train.Y-train.meanY))/2;

if ~isempty(valid)
  X = valid.X -  repmat(muX,[1 size(valid.X,2)]);
  X = X ./ repmat(sigmaX,[1 size(valid.X,2)]);
  
  X = [X; ones(1,size(valid.X,2))];
  valid.Z = X ./ repmat(sqrt(sum(X.^2)),[d 1]);
  
  valid.meanY = mean(valid.Y);
  valid.nY = norm(valid.Y-valid.meanY);
  valid.avgerr= mean(abs(valid.Y-valid.meanY))/2;
  valid.err = NaN*ones(1,maxepoch);
end

train.minerr = Inf;

if ~isempty(valid)
  valid.minerr = Inf;
end

tt = [];
W = W ./ repmat(sqrt(sum(W.^2,1)),[d 1]);
train.err = NaN*ones(1,maxepoch);
sumwu=0;
err_equ = 1;
verbose(0,'%5i: mae=%g (%g), eta=%g, gamma=%g\n',0,NaN,NaN,eta,gamma);

for t=1:maxepoch

  if rem(t,validinter)==0 | t == maxepoch
    tt = [tt t];  
    if ~isempty(valid)
      valid.O = min(1,max(-1,(sum(W'*valid.Z>=0,1)-n/2)/rho));
      valid.err(t)  = mean(abs(valid.O-valid.Y))/2;
      if valid.err(t) < valid.minerr
	valid.Wopt   = W;
	valid.minerr = valid.err(t);
	valid.topt   = t;
      end
    end
  end

  %
  % do one epoch
  %
  rp = randperm(m);
  Wbefore = W;
  [dW,train.O,sumwu] = cpdelta(W,train.Z,train.Y,rp,rho,eps,gamma,eta,mu,maxwu);
  W = W+dW;
  W = W ./ repmat(sqrt(sum(W.^2,1)),[d 1]);

  train.err(t)  = mean(abs(train.O-train.Y))/2;
  
  if train.err(t) < train.minerr
    train.Wopt   = Wbefore;
    train.minerr = train.err(t);
    train.topt   = t;
  end
  if t > 100 & train.err(t) > 0.499
    W = 1-2*rand(d,n);
    W = W ./ repmat(sqrt(sum(W.^2,1)),[d 1]);
    eta = eta0;
    gamma = gamma0;
  end
  
  if rem(t,validinter)==0 | t == maxepoch
    if ~isempty(valid)
      if  valid.err(t) == 0 & train.err(t) == 0, break; end
    else
      if train.err(t) == 0, break; end
    end
  end
  
  if ( t > 1 )
    %ht=min(t-1,10);
    %[ek,ed]=mylinreg(0:ht,train.err(t-ht:t));
    if train.err(t) > (1+(max_err_inc-1)*exp(-t/(maxepoch/3))) * train.err(t-1)
      eta = eta * lr_dec;
      %
      % To get the chance to escape from local minima we DO NOT say W = Wbefore;
      %
      % W = train.Wopt;
      err_equ = 1;
    elseif train.err(t) < train.err(t-1)
      eta = eta * lr_inc;
      err_equ = 1;
    else
      err_equ = err_equ + 1;
%      eta = eta*0.95;
    end
  end
  
  %
  % adjust gamma
  %
  % mu*rho/2*m - mu*sumwu
  gamma = gamma +  1e-3 * ( maxwu/2 - mu*sumwu/m );
  if gamma < 0, gamma = 0; end
    
  if rem(t,dispinter)==0 | t == maxepoch
    tcc=corr_coef(train.O,train.Y);
    if ~isempty(valid)   
      vcc=corr_coef(valid.O,valid.Y);
      verbose(0,'%5i: mae=%g (%g), corr=%g (%g), eta=%g, gamma=%g\n',t,train.err(t),valid.err(t),tcc,vcc,eta,gamma);
    else
      verbose(0,'%5i: mae=%g, corr=%g, eta=%g, gamma=%g\n',t,train.err(t),tcc,eta,gamma);
    end

    if PLOT
      figure(param.fig); clf reset;
      subplot(3,1,1);
      plot(train.xv,train.Y,'r.',train.xv,train.O,'bo');
      set(gca,'Ylim',ylim);
      title(sprintf('training data: mae=%g * %g',train.err(t)/train.avgerr,train.avgerr));
      
      subplot(3,1,2);
      if ~isempty(valid)
	plot(valid.xv,valid.Y,'r.',valid.xv,valid.O,'bo');
	set(gca,'Ylim',ylim);
	title(sprintf('validation data: mae=%g * %g',valid.err(t)/valid.avgerr,valid.avgerr));
      else
	title('NO VALIDATION DATA');
      end
      
      subplot(3,1,3);
      if ~isempty(valid)
	plot(1:length(train.err),train.err,'b-',tt,valid.err(tt),'k-');
	legend('training','valid');
      else
	plot(train.err,'b-');
	legend('training');
      end
      drawnow;
    end
  end
end

Wopt = W;

if param.train_wopt & ~isempty(train)
  verbose(0,'min train err (mae=%g) at epoch %i => using this weights\n',train.minerr,train.topt);
  Wopt = train.Wopt;
end

if param.valid_wopt & ~isempty(valid)
  verbose(0,'min valid err (mae=%g) at epoch %i => using this weights\n',valid.minerr,valid.topt);
  Wopt = valid.Wopt;
end

W =  Wopt(1:end-1,:) ./ repmat(train.sigmaX,[1 n]);
B =  Wopt(end,:)- ((train.muX'./train.sigmaX')*Wopt(1:end-1,:));

train.O = min(1,max(-1,(sum(Wopt'*train.Z>=0,1)-n/2)/rho));
train.clip_err = NaN;
if ~isempty(valid)
  valid.O = min(1,max(-1,(sum(Wopt'*valid.Z>=0,1)-n/2)/rho));
  valid.clip_err = NaN;
end

if PLOT
  figure(param.fig);
  subplot(3,1,1);
  plot(train.xv,train.Y,'r-',train.xv,train.O,'b-');
  set(gca,'Ylim',ylim);
  title(sprintf('training data: mae=%g * %g',train.err(t)/train.avgerr,train.avgerr));
  
  subplot(3,1,2);
  if ~isempty(valid)
    plot(valid.xv,valid.Y,'r-',valid.xv,valid.O,'b-');
    set(gca,'Ylim',ylim);
    title(sprintf('validation data: mae=%g * %g',valid.err(valid.topt)/valid.avgerr,valid.avgerr));
  else
    title('NO VALIDATION DATA');
  end
  
  subplot(3,1,3);
  if ~isempty(valid)
    plot(1:length(train.err),train.err,'bo-',tt,valid.err(tt),'kd-');
    legend('training','valid');
  else
    plot(train.err,'bo-');
    legend('training');
  end
  drawnow;
end



