function y = volterra_sim(model,data,DISP)
% by Stefan Haeusler 5/22/03 (haeusler@igi.tu-graz.ac.at)

if nargin < 3
   DISP = 0;
end


nu = model.nu;
ny = model.ny;
orders = model.orders;
nlinear = model.nlinear;
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



% first and higher order contributions


tIdx = repmat([1:orders+1],[nty 1]) + repmat([0:nty-1]',[1 orders+1]);

for nL = 1:nlinear
   X1 = reshape(u(tIdx,:).^nL,[nty orders+1 nu]);
   X = [X reshape(X1,[nty (orders+1)*nu])];
end


% calc output

for iy = 1:ny
   y(:,iy) = X*h(:,iy);
end

y = vertcat(ones(orders,ny)*diag(y(1,:)),y);     % fill up signal at the beginning

