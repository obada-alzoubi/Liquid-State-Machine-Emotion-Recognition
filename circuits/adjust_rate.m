function errorval = adjust_rate(nmc, what, p, Sin, nS, Tsim, target_rate)

learningrate = 0.02;
maxiter = 20;

pm=1;

pintern = get(nmc, 'pool');
idx = [pintern(p).neuronIdx];
npool = length(idx);

figure(1);
subplot(2,1,1);
bar(csim('get', idx, 'Vthresh'))
title('Vthresh before');


Vthresh  = csim('get', idx, 'Vthresh');
Vresting = csim('get', idx, 'Vresting');
Vreset   = csim('get', idx, 'Vreset');
Iinject  = csim('get', idx, 'Iinject');
Rm       = csim('get', idx, 'Rm');

learningrate = learningrate .* ones(1, npool);
target_rate = target_rate * ones(1, npool);


[resp, stim] = collect_sr_data(nmc, Sin, nS, Tsim,[],pm);
for s = 1:nS
  for n = 1:npool
    rate(s, n) = length(resp(s).channel(n).data)/Tsim;
  end
end

figure(2);
subplot(3,1,1);
bar(sort(mean(rate, 1)));
title('Rates before');
hold on;
plot([0 npool+1], mean(mean(rate))*[1 1], 'k--');
hold off;





iter = 1;
while (iter < maxiter)

  r = mean(rate, 1);
  errorval(iter, :) = (target_rate - r).^2;

  adjust = max(min((r-target_rate) .* learningrate, 0.9), -0.9) .* (Vthresh - Rm .* Iinject - Vresting);
  Vthresh = Vthresh + adjust;
  Vreset  = Vreset + adjust;
  csim('set', idx, 'Vthresh', Vthresh);
  csim('set', idx, 'Vreset',  Vreset);

  iter = iter +1;

  [resp, stim] = collect_sr_data(nmc, Sin, nS, Tsim,[],pm);


  for s = 1:nS
    for n = 1:npool
     rate(s, n) = length(resp(s).channel(n).data)/Tsim;
    end
  end

end








figure(2);
subplot(3,1,2);
bar(sort(mean(rate, 1)));
title('Rates after');
hold on;
plot([0 n+1], mean(mean(rate))*[1 1], 'k--');
hold off;



figure(1);
subplot(2,1,2)
bar(csim('get', idx, 'Vthresh'))
title('Vthresh after');

figure(2);
subplot(3,1,3)
plot(sum(errorval,2)/n)
title('error');

