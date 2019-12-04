function data = volterra_diag_plot(model,O,varargin)
% by Stefan Haeusler 08/04/03 (haeusler@igi.tu-graz.ac.at)

orders = model.data.orders;
nlinear = model.data.nlinear;
h = model.data.h;
Ts = model.data.Ts;


if nargin > 2
   data = varargin{1};
else
   data = volterra_diag_parameter(model,O);
end

if O == 0
   plot(data)
   set(gca,'xtick',[])
else
   plot([0:orders]*Ts,data)
   xlabel('time [sec]')
   axis tight  
end

title_str = sprintf('Model: %s; kernel diagonal %i order',model.info.type,O);
title(title_str)
