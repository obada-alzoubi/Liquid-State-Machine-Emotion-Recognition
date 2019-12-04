function []=plot_input_data(S,subpl)

subpl = num2str(subpl);
subplot(str2num(subpl(1)),str2num(subpl(2)),str2num(subpl(3)))
cla reset
axis off
hold on
set(gca,'Color',[1 1 1])

xSt = 0;
ySt = 0;
dx = 10;
dy = 5;
dyl = 0.8;

% plot stimuls name and input template name
text(xSt,ySt-dy,sprintf(' ''%s''',S.info.name),'Color',[1 0 0])
text(xSt,ySt-dy*2,sprintf(' %s',S.info.IT_name),'Color',[0 0 0])

for j = 1:length(S.channel)
   text(xSt + (j-1)*dx,ySt-3.5*dy,sprintf(' ''%s'' to input channel %i:',S.channel(j).name,S.channel(j).idx))
   for i = 1:length(S.channel(j).trans)

      % set noise string
      if S.channel(j).trans(i).dt_noise
         dt_noise_str = sprintf('dt = %g [sec]',S.channel(j).trans(i).dt_noise);
      else
         dt_noise_str = '';
      end

      % set 'actual parameter' string
      if (length(S.channel(j).trans(i).arg) == 1)
         value_str = sprintf('%0.3g',S.channel(j).trans(i).arg);
      elseif (length(S.channel(j).trans(i).arg) == 2)
         value_str = sprintf('%0.3g +/- %0.3g',S.channel(j).trans(i).arg(1),...
					 S.channel(j).trans(i).arg(2));
      end

      str1 = sprintf(' ''%s''',S.channel(j).trans(i).op);
      str2 = sprintf(' Value: %s',value_str);
      str3 = sprintf(' Distrib.: %0.3g +/- %0.3g %s',...
                    S.channel(j).trans(i).mean,...
                    S.channel(j).trans(i).std,S.channel(j).trans(i).unit);
      str4 = sprintf('             %s',dt_noise_str);


      text(xSt + (j-1)*dx,ySt - (i*3.5+1)*dy,str1,'Color',[0 0 1])
      text(xSt + (j-1)*dx,ySt - (i*3.5+2)*dy,str2)
      text(xSt + (j-1)*dx,ySt - (i*3.5+3)*dy,str3)
      text(xSt + (j-1)*dx,ySt - (i*3.5+4)*dy,str4)
   end
end

plot([xSt xSt+dx*j],[ySt-4*dy ySt-4*dy],'k')
axis([xSt xSt+dx*j ySt-dy*(length(S.channel(j).trans)*3.5+4) ySt])

