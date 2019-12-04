function model = volterra_fit(data,orders,DISP)
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


nlinear = 2; % order of nonlinearity

X = [];
for nl = 0:nlinear
   % generate inidices for p_m

   nnl = (orders+1)^nl;
   nl_idx = repmat([0:nnl-1]',[1,nl]);
   nl_idx = floor(nl_idx./repmat((orders+1).^[0:nl-1],[nnl,1]));
   nl_idx = mod(nl_idx,(orders+1));
   nl_idx = unique(sort(nl_idx,2),'rows');

   % generate p_m

   tidx = repmat([1:nty]',[1 nl]);

   p = zeros(nty,size(nl_idx,1));
   for i = 1:size(nl_idx,1)
      j = tidx + repmat(nl_idx(i,:),[nty 1]);
      p(:,i) = prod(u(j),2);
   end

   X = [X p];
end

clear p

% do linear regression

for iy = 1:ny
   h(:,iy) =  X\y(:,iy);
%   h(:,iy) =  pinv(X.'*X)*X.'*y(:,iy);
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
