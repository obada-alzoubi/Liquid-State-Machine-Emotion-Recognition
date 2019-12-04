function model = volterra_fit(data,orders,DISP)
% by Stefan Haeusler 5/22/03 (haeusler@igi.tu-graz.ac.at)

if nargin < 3
   DISP = 0;
end

% read input signals

y = data.y(orders+1:end,:);
u = data.u;

[u,mu,stdu] = prestd(u);

% mmu = minmax(u')';
% u = u - repmat(mmu(1,:),[size(u,1) 1]);
% u = u ./repmat(diff(mmu),[size(u,1) 1]);

nty = size(y,1);
nt = size(u,1);

ny = size(y,2);
nu = size(u,2);


% zero order contributions
X = ones(nty,1);


% first order contributions


tIdx = repmat([1:orders+1],[nty 1]) + repmat([0:nty-1]',[1 orders+1]);

X1 = reshape(u(tIdx,:),[nty orders+1 nu]);
X = [X reshape(X1,[nty (orders+1)*nu])];


% second order contributions


u1Idx = triu(repmat([1:nu],[nu 1]));
u1Idx = u1Idx(u1Idx~=0);

u2Idx = triu(repmat([1:nu]',[1 nu]));
u2Idx = u2Idx(u2Idx~=0);

o1Idx = triu(repmat([1:orders+1],[orders+1 1]));
o1Idx = o1Idx(o1Idx~=0);

o2Idx = triu(repmat([1:orders+1]',[1 orders+1]));
o2Idx = o2Idx(o2Idx~=0);

for iu = 1:length(u1Idx)
   X2 = X1(:,o1Idx,u1Idx(iu)).*X1(:,o1Idx,u2Idx(iu));
   X = [X X2];
end


% do linear regression

for iy = 1:ny
%   h(:,iy) =  X\y(:,iy);
   h(:,iy) =  pinv(X.'*X)*X.'*y(:,iy);
   o(:,iy) = X*h(:,iy);
end

Error = mean((o-y).^2);

model.mu = mu;
model.stdu = stdu;
model.nu = nu;
model.ny = ny;
model.orders = orders;
model.h = h;
model.Error = Error;
model.Ts = data.Ts;
