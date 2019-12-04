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


% calc output

for iy = 1:ny
   y(:,iy) = X*h(:,iy);
end


y = vertcat(ones(orders,ny)*diag(y(1,:)),y);     % fill up signal at the beginning

