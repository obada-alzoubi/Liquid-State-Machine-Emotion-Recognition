function [y] = volterra_sim(model,data,DISP)
% by Stefan Haeusler 7/10/03 (haeusler@igi.tu-graz.ac.at)

if nargin < 3
   DISP = 0;
end


nu = model.nu;
ny = model.ny;
orders = model.orders;
nlinear = model.nlinear;
a = model.a;


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

orders = orders + 1;

%
% generate regressors
%

p_m = [];
for nl = 0:nlinear
   % generate inidices for p_m

   nnl = orders^nl;
   nl_idx = repmat([0:nnl-1]',[1,nl]);
   nl_idx = floor(nl_idx./repmat(orders.^[0:nl-1],[nnl,1]));
   nl_idx = mod(nl_idx,orders);
   nl_idx = unique(sort(nl_idx,2),'rows');

   % generate p_m

   tidx = repmat([1:nty]',[1 nl]);

   p = zeros(nty,size(nl_idx,1));
   for i = 1:size(nl_idx,1)
      j = tidx + repmat(nl_idx(i,:),[nty 1]);
      p(:,i) = prod(u(j),2);
   end

   p_m = [p_m p];
end


clear p

lp_m = size(p_m,2);

%
% span output on input base vectors
%

clear y
for iy = 1:ny
   y(:,iy) = p_m*a(:,iy);
end

orders = orders - 1;

y = vertcat(ones(orders,ny)*diag(y(1,:)),y);     % fill up signal at the beginning


