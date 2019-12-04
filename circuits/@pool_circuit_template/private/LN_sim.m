function y = volterra_sim(model,data,DISP)
% by Stefan Haeusler 7/10/03 (haeusler@igi.tu-graz.ac.at)

if nargin < 3
   DISP = 0;
end


nu = model.nu;
ny = model.ny;
orders = model.orders;
nlinear = model.nlinear;
hl = model.hl;
hst = model.hst;


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


%
% do dynamic linear computation
%


% zero order contributions

X = ones(nty,nu);


% first order contributions


tIdx = repmat([1:orders+1],[nty 1]) + repmat([0:nty-1]',[1 orders+1]);

X1 = reshape(u(tIdx,:),[nty orders+1 nu]);
X = [X reshape(X1,[nty (orders+1)*nu])];


% calc output

for iy = 1:ny
   lo(:,iy) = X*hl(:,iy);
end


%
% do static nonlinear computation
%

for iy = 1:ny

   X= lo(:,iy).^0;

   for nl = 2:nlinear
      X = [X lo(:,iy).^nl];
   end

   y(:,iy) = X*hst(:,iy);
end


y = vertcat(ones(orders,ny)*diag(y(1,:)),y);     % fill up signal at the beginning


