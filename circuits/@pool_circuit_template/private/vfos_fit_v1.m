function model = vfos_fit(data,orders,nlinear,DISP)
% by Stefan Haeusler 01/07/04 (haeusler@igi.tu-graz.ac.at)

if nargin < 4
   DISP = 1;
end

if (nlinear ~= 1) && (nlinear ~= 2)
   error('Very fast orthogonal search is only implemented up to 2nd order.')
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

if DISP, fprintf('\n Calculate expectation values of regressors.\n'), end

keyboard


%%%%%%%%%%%%%%%%
% calculate E_Pm

E_Pm2 = 1;
for nO = 1:orders
   E_Pm2(1+nO) = mean(u(nO:end-orders+nO));
end
llp_m = [1 orders+1];

if (nlinear == 2)

   llp_m(3) = (orders^nl-orders)/2 + orders*2 + 1;

   for nO1 = 1:orders
      for nO2 = nO1:orders
         E_Pm2(end+1) = u(nO1:end-orders+nO1)'*u(nO2:end-orders+nO2)/nty;
      end
   end
end

%%%%%%%%%%%%%%%%%%%
% calculate E_PmPr

% nO1 = 0 and nO2 = 0
E_PmPr2 = 1;

for nO1 = 1:orders

   % nO2 = 0

   E_PmPr2(nO1+1,1) = mean(u(nO1:end-orders+nO1));

   for nO2 = 1:nO1
      E_PmPr2(nO1+1,nO2+1) = u(nO1:end-orders+nO1)'*u(nO2:end-orders+nO2)/nty;
   end
end

if (nlinear == 2)

   nO1 = orders;

   for nO1a = 1:orders
    for nO1b = nO1a:orders
      nO1 = nO1 + 1


      h = u(nO1a:end-orders+nO1a).*u(nO1b:end-orders+nO1b);

      % nO2 = 0

      E_PmPr2(nO1+1,1) = mean(h);

      for nO2 = 1:orders
         E_PmPr2(nO1+1,nO2+1) = mean(h.*u(nO2:end-orders+nO2));
      end

      nO2 = orders;
      for nO2a = 1:orders
       for nO2b = nO2a:orders
         nO2 = nO2 + 1;
         h2 = u(nO2a:end-orders+nO2a).*u(nO2b:end-orders+nO2b);
         E_PmPr2(nO1+1,nO2+1) = mean(h.*h2);
       end
      end

    end
   end

end



%%%%%%%%%%%%%%%%%

p_m = [];
for nl = 0:nlinear
   % disp(nl)

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

if DISP, fprintf(' Calculate coefficients.\n'), end

E_Pm = mean(p_m,1);
E_PmPr = p_m'*p_m/nty;

D = E_Pm';

alpha = [];
for m = 2:lp_m
   for r = 2:m-1
      i = [1:r-1];
      D(m,r) = E_PmPr(m,r) - alpha(r,i)*D(m,i)';
   end

   r = m;
   i = [1:r-1];
   alpha(r,i) = D(r,i)./diag(D(i,i))';
   D(m,r) = E_PmPr(m,r) - alpha(r,i)*D(m,i)';
end

%
% span output on input base vectors
%

if DISP, fprintf(' Span output onto base vectors.\n'), end

for iy = 1:ny
   C = [];
   for m = 1:lp_m
      r = [1:m-1];
      C(m) = mean(y(:,iy).*p_m(:,m)) - alpha(m,r)*C(r)';
   end
   g(:,iy) = C'./diag(D);
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

%
% calculate model error
%

clear o
for iy = 1:ny
 for nl = 0:nlinear
   o(:,iy) = p_m(:,1:llp_m(nl+1))*a(1:llp_m(nl+1),iy);
   Error(nl+1,iy) = mean((o-y(:,iy)).^2);
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
