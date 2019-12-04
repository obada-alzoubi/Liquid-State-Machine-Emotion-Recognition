function y = wiener_fit(model,data,nlinear,DISP)

if nargin < 4
   DISP = 0;
end

% for shorter notation

nu = model.nu;
ny = model.ny;
orders = model.orders;
P = model.P;

h0 = model.h0;
h1 = model.h1;
h2 = model.h2;
% h1(1,1,:) = model.h1;
% h2(1,1,1,:,:) = model.h2;

% read input signals

u = data.u;
nt = size(u,1);

if nu > size(u,2)

   % fill additional input channel with zero input
   u = [u zeros(nt,size(u,2))];
elseif nu < size(u,2)

   % delete additional input channels
   u(:,nu+1:end) = [];
end


nty = nt - orders;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate wiener terms  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

y = zeros(nty,ny);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% zero order term
%


O0 = repmat(h0,[nty 1]);

if any(nlinear==0)
   y = y + O0;
end


if DISP
   figure
   subplot(211)
   plot(O0)
   title('O0')
   subplot(212)
   plot(y0)
   title('y')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first order term
%
% (Note: loops are not necessary if xcorr([y u]) is used
%        but then many irrelevant crosscorrs are also computed)


O1 = zeros(nty,ny);

for iy = 1:ny
   for iu = 1:nu
      o = conv(u(:,iu),h1(iy,iu,:));
      O1(:,iy) = O1(:,iy) + o(orders+1:end-orders);
   end
end


if any(nlinear==1)
   y = y + O1;
end

if DISP
   figure
   subplot(211)
   plot(O1)
   title('O1')
   subplot(212)
   plot(y)
   title('y')
end


%%%%%%%%%%%%%%%%%%%%
% second order term


O2 = zeros(nty,ny);

%for iy = 1:ny
%   for iu1 = 1:nu
%      for iu2 = 1:nu
%         o = conv2(reshape(h2(iy,iu1,iu2,:,:),[orders+1 orders+1]),u(:,iu1)*u(:,iu2)');
%         o = diag(o);
%	 O2(:,iy) = O2(:,iy) + o(orders+1:end-orders);
%      end
%
%      % subtract diagonal terms
%
%      O2(:,iy) = O2(:,iy) - P(iu1)*trace(reshape(h2(iy,iu1,iu1,:,:),orders+1,orders+1));
%   end
%end

for iy = 1:ny
   for iu1 = 1:nu
      for iu2 = 1:nu
         o = zeros(nty,1);
         for tau2 = 1:orders+1
            o_b = conv(u(:,iu1),h2(iy,iu1,iu2,:,tau2));
            o_b = o_b(orders+1:end-orders);
	    o = o + u(orders+2-tau2: end + 1 - tau2,iu2).*o_b;
	 end
	 O2(:,iy) = O2(:,iy) + o;
      end

      % subtract diagonal terms

      O2(:,iy) = O2(:,iy) - P(iu1)*trace(reshape(h2(iy,iu1,iu1,:,:),orders+1,orders+1));
   end
end

if any(nlinear==2)
   y = y + O2;
end

y = vertcat(ones(orders,ny)*diag(y(1,:)),y);     % fill up signal at the beginning


if DISP
   figure
   subplot(211)
   plot(O2)
   title('O2')
   subplot(212)
   plot(y)
   title('y')
end


