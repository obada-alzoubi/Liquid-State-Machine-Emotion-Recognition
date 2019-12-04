function plot_stimulus(Sin,Tmax)

  if nargin < 2, Tmax=[]; end
  
  if isempty(Tmax)
    plot_channels(Sin.channel,Sin.info(1).Tstim);
  else
    plot_channels(Sin.channel,Tmax);
  end
  
  ylabel('channel#');
  xlabel('time [sec]');
  title('stimulus','fontweight','bold');

