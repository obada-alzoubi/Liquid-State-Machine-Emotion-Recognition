function model = os_fit(data,orders,nlinear,DISP)
% by Stefan Haeusler 5/22/03 (haeusler@igi.tu-graz.ac.at)

if nargin < 4
   DISP = 0;
end

% read input signals


y = data.y(orders + 1:end,:);
u = data.u;

nty = size(y,1);
nt = size(u,1);

ny = size(y,2);
nu = size(u,2);

orders = orders + 1;

%
% generate regressors
%

p_m = [];
for nl = 0:nlinear
   disp(nl)

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

   llp_m(nl+1) = size(p_m,2);
end

clear p

lp_m = size(p_m,2);

%
% orthogonalize input base vector
%

p_m_norm = 1/(p_m(:,1)'*p_m(:,1));
alpha = zeros(lp_m,lp_m);

for m = 2:lp_m
   fprintf('orthog. %i/%i\n',m,lp_m)
   alpha(m,1:m-1) = [p_m(:,1:m-1)'*p_m(:,m)]'.*p_m_norm;
   p_m(:,m) = p_m(:,m) - p_m(:,1:m-1)*alpha(m,1:m-1)';
   p_m_norm(m) = 1/(p_m(:,m)'*p_m(:,m));
end

%
% span output on input base vectors
%

for nl = 0:nlinear
 clear o g
 for iy = 1:ny
   g(:,iy) = [y(:,iy)'*p_m(:,1:llp_m(nl+1))]'.*p_m_norm(1:llp_m(nl+1))';
   o(:,iy) = p_m(:,1:llp_m(nl+1))*g;
 end
 Error(nl+1,1) = mean((o-y).^2);
end



%
% calculate coefficients for unorthogonalized input base vectors
%

for iy = 1:ny
 for m = 1:lp_m

   v(m) = 1;
   for i = m+1:lp_m
      r = m:i-1;
      v(i) = - alpha(i,r)*v(r)';
   end

   i = m:lp_m;
   a(m,iy) = v(i)* g(i,iy);

 end
end

orders = orders - 1;

model.nu = nu;
model.ny = ny;
model.orders = orders;
model.nlinear = nlinear;
model.a = a;
model.Error = Error;
model.Ts = data.Ts;
