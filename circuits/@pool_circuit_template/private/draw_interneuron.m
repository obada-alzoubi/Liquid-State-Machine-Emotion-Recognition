function draw_interneuron(X,Y,nFig,name)
%
% Draws the icon of a interneuron cell
%

figure(nFig)
axis off
hold on

dRad = 2*pi/100;
Rad = 0:dRad:2*pi;
x = cos(Rad) * 6;
y = sin(Rad) * 6;
fill(X+x,Y+y,'k-')
text(X+8,Y+5,name)
