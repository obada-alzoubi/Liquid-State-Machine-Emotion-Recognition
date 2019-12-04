function model = LN_fit(data,orders,nlinear,DISP)
% by Stefan Haeusler 7/10/03 (haeusler@igi.tu-graz.ac.at)

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


%
% do dynamic linear computation
%


% zero order contributions

X = ones(nty,nu);


% first order contributions


tIdx = repmat([1:orders+1],[nty 1]) + repmat([0:nty-1]',[1 orders+1]);

X1 = reshape(u(tIdx,:),[nty orders+1 nu]);
X = [X reshape(X1,[nty (orders+1)*nu])];

% do linear regression

for iy = 1:ny
   hl(:,iy) = X\y(:,iy);
%   h1(:,iy) =  pinv(X.'*X)*X.'*y(:,iy);

   hl(1,iy) = 0;
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

   % do linear regression

   hst(:,iy) = X\y(:,iy);
%   hst(:,iy) =  pinv(X.'*X)*X.'*y(:,iy);

   o(:,iy) = X*hst(:,iy);
end

Error = mean((o-y).^2);

model.nu = nu;
model.ny = ny;
model.orders = orders;
model.nlinear = nlinear;
model.hl = hl;
model.hst = hst;
model.Error = Error;
model.Ts = data.Ts;
