function data = volterra_diag_parameter(model,O)
% by Stefan Haeusler 08/04/03 (haeusler@igi.tu-graz.ac.at)

orders = model.data.orders;
nlinear = model.data.nlinear;
h = model.data.h;
Ts = model.data.Ts;

if O > nlinear
   error(sprintf('Maximum order of nonlinearity is %g.',nlinear))
end

if O == 0
   data = h(1);
else
   data = h(2+(orders+1)*(O-1) : 1+(orders+1)*O);
   data = data(end:-1:1);
end
