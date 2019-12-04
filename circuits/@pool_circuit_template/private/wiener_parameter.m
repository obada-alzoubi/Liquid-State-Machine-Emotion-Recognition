function data = wiener_parameter(model,O)

orders = model.data.orders;

h0 = model.data.h0;
h1 = model.data.h1;
h2 = model.data.h2;
h1 = h1(:);
h2 = reshape(h2,(orders+1)*[1 1]);

if O == 0
   data = h0;
elseif O == 1
   data = h1;
elseif O == 2
   data = h2;
else
   error('Maximum order of nonlinearity is two!')
end


