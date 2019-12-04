function model = volterra_fit(data,orders,nlinear,DISP)
% by Stefan Haeusler 5/22/03 (haeusler@igi.tu-graz.ac.at)

if nargin < 3
   DISP = 0;
end

% read input signals

y = data.y(orders+1:end,:);
u = data.u;


nty = size(y,1);
nt = size(u,1);

ny = size(y,2);
nu = size(u,2);


% zero order contributions


X = ones(nty,1);


% first and higher order contributions

tIdx = repmat([1:orders+1],[nty 1]) + repmat([0:nty-1]',[1 orders+1]);

for nL = 1:nlinear
   X1 = reshape(u(tIdx,:).^nL,[nty orders+1 nu]);
   X = [X reshape(X1,[nty (orders+1)*nu])];
end


% do linear regression

for iy = 1:ny
%   h(:,iy) =  X\y(:,iy);
   h(:,iy) =  pinv(X.'*X)*X.'*y(:,iy);
   o(:,iy) = X*h(:,iy);
end

Error = mean((o-y).^2);

model.nu = nu;
model.ny = ny;
model.orders = orders;
model.nlinear = nlinear;
model.h = h;
model.Error = Error;
model.Ts = data.Ts;
