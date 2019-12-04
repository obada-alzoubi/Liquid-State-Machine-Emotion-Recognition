function y = volterra_sim(model,data,DISP)
% by Stefan Haeusler 7/10/03 (haeusler@igi.tu-graz.ac.at)

if nargin < 3
   DISP = 0;
end


nu = model.nu;
ny = model.ny;
orders = model.orders;
h = model.h;

% read input signals

u = data.u;

nt = size(u,1);
nty = nt - orders;

if nu > size(u,2)

   % fill additional input channel with zero input
   u = [u zeros(nt,size(u,2))];
elseif nu < size(u,2)

   % delete additional input channels
   u(:,nu+1:end) = [];
end

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

% empty first order output contributions
X0 = [X zeros(nty,orders*ny)];

% calc output

for iy = 1:ny
   y(:,iy) = X0*h(:,iy);
end

y = vertcat(zeros(orders,ny),y);     % fill up signal at the beginning

%
% calculate feedback part
%

for iy = 1:ny
   hy = h(end-orders*ny+1:end,iy)';
   hy = reshape(hy,[orders ny])';

   for nstep = orders+1:nt
      y(nstep,iy) = trace(hy*y(nstep-orders:nstep-1,:)) + y(nstep,iy);
   end
end

