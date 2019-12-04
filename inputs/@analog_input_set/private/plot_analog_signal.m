function []=plot_analog_signal(S,offset,subpl)

subpl = num2str(subpl);
subplot(str2num(subpl(1)),str2num(subpl(2)),str2num(subpl(3)))
cla reset
hold on
axis on
set(gca,'Color',[1 1 1])

YTick = [];
YTickLabel = [];
YNameTick = [];
YNameTickLabel = [];

TstimMax = 0;

for nS = 1:length(S)

   % not implemented feature of neuron index change

   INidx = 1:max(horzcat(S{nS}.channel.idx));

   % search for the number of input neurons

   idx = [];
   
   % set input signal to each neuron to zero
   dt = S{nS}.info.Tstim * ones(1,max(INidx));
   [data{1:max(INidx)}] = deal([0 0]);

   for nI = 1:length(S{nS}.channel)
      i = INidx(S{nS}.channel(nI).idx);
      idx(i) = 1;

      % check which signal has to be interpolated

      t1 = ([1:length(data{i})] - 1)*dt(i);
      t2 = ([1:length(S{nS}.channel(nI).data)] - 1)*S{nS}.channel(nI).dt;

      % scale data apropriatly in time
      if S{nS}.channel(nI).dt < dt(i)
         data{i} = interp1(t1,data{i},t2,'linear');
         chdata = S{nS}.channel(nI).data;
 
         dt(i) = S{nS}.channel(nI).dt;
      elseif S{nS}.channel(nI).dt > dt(i)
         chdata = interp1(t2,S{nS}.channel(nI).data,t1,'linear');
      else
         chdata = S{nS}.channel(nI).data;
      end
      % if one signal is short keep its last value to the end
      data{i}(length(data{i})+1:length(chdata)) = data{i}(end);
      chdata(length(chdata)+1:length(data{i})) = chdata(end);

      j =  1:length(chdata);
      data{i} = data{i} + chdata;
   end

   idx = find(idx);
   [data{1:length(idx)}] = deal(data{idx});
   data(length(idx)+1:end) = [];
   dt = dt(idx);

   y = offset(2) + 1 : offset(2) + length(idx);

   % save data for name label

   YNameTick(end+1) = mean(y);
   if length(S) > 1
      YNameTickLabel{end+1} = sprintf('''%s'' (Trace %i)',S{nS}.info.name,nS);
   else
      YNameTickLabel{end+1} = sprintf('''%s''',S{nS}.info.name);
   end

   % plot analog signals

   for j = 1:length(idx)
      % write input neuron number

      YTick(end+1) =  y(j);
      YTickLabel{end+1} =  sprintf('%i',idx(j));

      % line of inputs signal
      x = dt(j):dt(j):dt(j)*length(data{j});
      h=plot3([x+offset(1)],[y(j)*ones(size(data{j}))],[data{j}+offset(3)],'b-');
   end

   offset(2) = y(end)+3;

   TstimMax = max(TstimMax,S{nS}.info.Tstim);
end

% set axis
view([50 80])
v = axis;
v(1) = 0;
v(2) = TstimMax;
v(3) = 0;
v(4) = offset(2)-2;
axis(v)

% write name labels
for i = 1: length(YNameTick)
   text(v(2) *1.15,YNameTick(i),v(5),YNameTickLabel{i},'Color',[1 0 0])
end


view([50 80])
grid on
xlabel('t [sec]')
ylabel('Input channel')
zlabel(sprintf('I [A]'))

%set(gca,'YTick',[])
set(gca,'YTick',YTick)
set(gca,'YTickLabel',YTickLabel)


