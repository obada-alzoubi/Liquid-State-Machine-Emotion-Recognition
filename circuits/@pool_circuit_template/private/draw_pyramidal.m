function draw_pyramidal(X,Y,nFig,name)
%
% Draws the icon of a pyramidal cell
%

figure(nFig)
axis off
hold on

fill(X + [-5 5 0 -5],Y + [-10 -10 10 -10],'k-')
text(X + 5,Y + 5,name)



