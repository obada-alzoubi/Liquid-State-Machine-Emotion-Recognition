function wiener_plot(model,O,varargin)

Ts = model.data.Ts;
orders = model.data.orders;

if nargin > 2
   data = varargin{1};
else
   data = wiener_parameter(model,O);
end

if O == 0
   plot(data)
   set(gca,'xtick',[])
elseif O == 1
   plot([0:orders]*Ts,data)
   xlabel('time [sec]')
   axis tight
elseif O == 2
   surf([0:orders]*Ts,[0:orders]*Ts,data)
   xlabel('time [sec]')
   ylabel('time [sec]')
   view(45,45)
   axis tight
else
   error('Maximum order of nonlinearity is two!')
end

disp('ATTENTION: no title ploted')
%title_str = sprintf('Circuit: %s Model: %s; %i. order kernel',get(model.info.circuit.template,'name'),model.info.type,O);
%title(title_str)


