function crosscorr_channels(channel)
Tsim = 200;

if ~isempty(find([channel(:).spiking]==0))
  fprintf('Sorry, works for spike trains only!\n');
  return;
end

dt = 0.001; % csim('get', 'dt');
gsigma = 0.005;    % in [ms] !!!
g = exp(-([-200:1:200]-0).^2/(2*(gsigma/dt).^2));
tauek = 0.003;
ek = exp(-[0:1:400]./(tauek/dt));


figure
for c1 = 1:length(channel)
  for c2 = c1:length(channel)

    a = zeros(1, Tsim/dt+1);
    a(round(channel(c1).data/dt)+1) = 1;
    a = conv(a, g);

    b = zeros(1, Tsim/dt+1);
    b(round(channel(c2).data/dt)+1) = 1;
    b = conv(b, g);

    [ccab, cct] = crosscorr(a-mean(a), b-mean(b), round(1/dt), 'coeff');

    subplot(length(channel), length(channel), (c1-1)*length(channel)+c2);
    plot(cct*dt, ccab);
    axis([-1 1 -0.2 1]);
  end
end

