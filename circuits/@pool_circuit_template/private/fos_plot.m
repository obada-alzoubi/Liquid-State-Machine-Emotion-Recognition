function [] = fos_plot(model,O,varargin)

orders = model.data.orders;
nlinear = model.data.nlinear;
Ts = model.data.Ts;

if nargin > 2
   data = varargin{1};
else
   data = fos_parameter(model,O);
end

if O == 0
   plot(data)
   set(gca,'xtick',[])
elseif O == 1
   plot([0:orders]*Ts,data)
   xlabel('time [sec]')
   axis tight
elseif O == 2
   surfc([0:orders]*Ts,[0:orders]*Ts,data)
   xlabel('time [sec]')
   ylabel('time [sec]')
   view(45,45)
   axis tight
else
   error('Maximal allowed order of nonlinearity is two!')
end

title_str = sprintf('Circuit: %s Model: %s; %i. order kernel',get(model.info.circuit.template,'name'),model.info.type,O);
title(title_str)


