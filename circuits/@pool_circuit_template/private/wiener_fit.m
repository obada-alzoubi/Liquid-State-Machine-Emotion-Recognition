function model = wiener_fit(data,orders,DISP)
% by Stefan Haeusler 5/22/03 (haeusler@igi.tu-graz.ac.at)

if nargin < 3
   DISP = 0;
end

% read input signals

y = data.y(orders+1:end,:); % delete unpredictable start piece
u = data.u;

if DISP
   figure
   subplot(211)
   plot(u)
   title('u')
   subplot(212)
   plot(y)
   title('y')
end


nt = size(u,1);
nty = size(y,1);
nu = size(u,2);
ny = size(y,2);


% check if inputs are white noise signal

P = mean(u.^2); % actualy this is P/(delta t) so the real P is much lower,
		% but the term drops out anyway below

for iu = 1:nu
   cc = crosscorr(u(:,iu),u(:,iu),'biased');
   if length(find(cc > 0.3*P(iu))) > 1
%   if length(find(cc > 0.3*P(iu))) > 1e6
      figure
      plot(cc)
      title(sprintf('Autocorrelation of input channel %i',i))
      warning('No white noise input signal!')
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate kernels       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% zero order term
%

h0 = mean(y);

% calculate remaining output

O0 = repmat(h0,[nty 1]);
y0 = y - O0;


if DISP
   figure
   subplot(311)
   plot(O0)
   title('O0 (h0)')
   subplot(312)
   plot(y0)
   title('y0')
   subplot(313)
   plot(O0)
   title('y fit')
end

% calc mse

Error(1,:) = mean(y0.^2,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first order term
%
% (Note: loops are not necessary if xcorr([y u]) is used
%        but then many irrelevant crosscorrs are also computed)


for iy = 1:ny
   for iu = 1:nu
      cc = crosscorr(y0(:,iy),u(:,iu),orders)/nty;
      h1(iy,iu,:) = cc(1:orders+1)/P(iu);

      if DISP > 1
         figure
	 plot(reshape(h1(iy,iu,:),1,orders+1))
	 title(sprintf('kernel h1(y%i,u%i)',iy,iu))
      end
   end
end

% calculate remaining output

O1 = zeros(nty,ny);

for iy = 1:ny
   for iu = 1:nu
      o = conv(u(:,iu),h1(iy,iu,:));
      O1(:,iy) = O1(:,iy) + o(orders+1:end-orders);
   end
end

y1 = y0 - O1;

if DISP
   figure
   subplot(311)
   plot(O1)
   title('O1')
   subplot(312)
   plot(y1)
   title('y1')
   subplot(313)
   plot(O0+O1)
   title('y fit')
end

% calc mse

Error(2,:) = mean(y1.^2,1);


%%%%%%%%%%%%%%%%%%%%
% second order term


for iy = 1:ny
   for iu1 = 1:nu
      for iu2 = 1:nu
         for tau1 = 1:orders+1
            yx = y1(:,iy).*u( orders + 2 - tau1 : end + 1 - tau1 ,iu1);
            cc = crosscorr(yx,u(:,iu2),orders)/nty;
            h2(iy,iu1,iu2,tau1,:) = cc(1:orders+1)/(2*P(iu1)*P(iu2));
	 end

	 if DISP > 1
	    figure
            subplot(nu,nu,iu1+(iu2-1)*nu)
            surf(reshape(h2(iy,iu1,iu2,:,:),[orders+1 orders+1]))
	    title(sprintf('h2 (y%i,x%i,x%i)',iy,iu1,iu2))
	 end
      end
   end
end

% calculate remaining output

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

y2 = y1 - O2;

if DISP
   figure
   subplot(311)
   plot(O2)
   title('O2')
   subplot(312)
   plot(y2)
   title('y2')
   subplot(313)
   plot(O0+O1+O2)
   title('y fit')
end


% calc mse

Error(3,:) = mean(y2.^2,1);

% calc orthogonality

nO0 = sqrt(O0'*O0);
nO1 = sqrt(O1'*O1);
nO2 = sqrt(O2'*O2);

orthog(1,1) = (O0'*O0)/(nO0*nO0);
orthog(1,2) = (O0'*O1)/(nO0*nO1);
orthog(1,3) = (O0'*O2)/(nO0*nO2);
orthog(2,2) = (O1'*O1)/(nO1*nO1);
orthog(2,3) = (O1'*O2)/(nO1*nO2);
orthog(3,3) = (O2'*O2)/(nO2*nO2);

model.nu = nu;
model.ny = ny;
model.orders = orders;
model.P = P;
model.h0 = h0;
model.h1 = h1;
% model.h1 = h1(:);
model.h2 = h2;
% model.h2 = reshape(h2,[length(h2) length(h2)]);
model.Error = Error;
model.orthog = orthog;
model.Ts = data.Ts;
