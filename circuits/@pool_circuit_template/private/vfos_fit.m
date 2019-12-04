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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Korenberg version

% E_Pm2

mu = mean(u);
E_Pm2 = 1;
m = 1;
E_Pm2(m+1) = mu;
for m = 2:orders
   i = 0:m-2;
   E_Pm2(m+1) = mu - 1/nt * sum(u(nt-i));
end

for i = 0:orders-1
   n = i:(nt-1);
   phi_uu(i+1) = 1/nt*sum(u(n+1).*u(n-i+1));
end

if (nlinear == 2)

   for J1 = 0:orders-1
      for J2 = J1:orders-1
         k = 0:J1-1;
         E_Pm2(end+1) = phi_uu(J2-J1+1) - 1/nt * sum(u(k+nt-J1+1).*u(k+nt-J2+1));
      end
   end
end

% E_PmPr2

E_PmPr2(1,1) = 1;
for m = 1:orders
   E_PmPr2(m+1,1+1) = phi_uu(m-1+1);
   for r = 2:m
      j = 0:r-2;
      E_PmPr2(m+1,r+1) = phi_uu(m-r+1) - 1/nt * sum( u(nt-m+2+j).*u(nt-r+2+j));
   end
end

if (nlinear == 2)

   for i = 0:orders-1
      for j = 0:orders-1
         n = max(i,j):(nt-1);
         phi_uuu(i+1,j+1) = 1/nt * sum( u(n+1).*u(n-i+1).*u(n-j+1));
      end
   end

   m = orders;
   for J1 = 0:orders-1
      for J2 = J1:orders-1
         m = m + 1;
         for r = 1:orders

	    Z1 = min(J1,r-1);
	    A = J1 + r - 1 - Z1;
	    Z2 = min(A,J2);
	    Z3 = A + J2 - Z2;

	    k = 0:Z1-1;

	    E_PmPr2(m+1,r+1) = phi_uuu(Z2-Z1+1,Z3-Z1+1) - ...
	                       1/nt*sum( u(k+nt-Z1+1).*u(k+nt-Z2+1).*u(k+nt-Z3+1));
	 end
      end
   end
   
   for i = 0:orders-1
      for j = i:orders-1
         for k = j:orders-1
	    fprintf('i: %i/%i j: %i/%i k: %i/%i\n',i,orders-1,j,orders-1,k,orders-1)
            n = max([i j k]):(nt-1);
            phi_uuuu(i+1,j+1,k+1) = 1/nt * sum( u(n+1).*u(n-i+1).*u(n-j+1).*u(n-k+1));
	 end
      end
   end

   m = orders;
   for I1 = 0:orders-1
      for J1 = I1:orders-1
         m = m + 1;
	 r = orders;
	 for I2 = 0:orders-1
	    for J2 = I2:orders-1
	       r = r + 1;
	       if (r <= m)
	          Z1 = min(I1,I2);
		  Z4 = max(J1,J2);
		  A = I1 + I2 - Z1;
		  B = J1 + J2 - Z4;
		  Z2 = min(A,B);
		  Z3 = A + B - Z2;
		  
		  k = 0:Z1-1;
		  
                  E_PmPr2(m+1,r+1) = phi_uuuu(Z2-Z1+1,Z3-Z1+1,Z4-Z1+1) - ...
		                     1/nt * sum( u(k+nt-Z1+1).*u(k+nt-Z2+1).*u(k+nt-Z3+1).*u(k+nt-Z4+1));

	       end
	    end
	 end
      end
   end

end

... still to implement the correct p_m below ...


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

