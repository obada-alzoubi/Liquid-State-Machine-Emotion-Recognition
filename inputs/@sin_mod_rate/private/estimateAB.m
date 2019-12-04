function this=init(this)
%
%  this=init(this) initializes the internal variables 'A' and 'B' 
%    which are used to scale the randomly generated rate r(t) into
%    the range [0,1]. Called whenever the property 'fmod' has changed. 
%  
%    ** This methode is not intended to be called by the user; 
%    ** but it dos not hurt anyone.
%
%  See also SIN_MOD_RATE/SIN_MOD_RATE, SIN_MOD_RATE/GENERATE
%
%  Author: Thomas Natschlaeger, 11/2001, tnatschl@igi.tu-graz.ac.at
%

%
% Here we try to get an estimate for two scaling parameters 
% A and B which are subsequently used to scale r(t) such that
% that 0 <= r(t) <= 1 for each time t (0<= t <=Tmax)
% randomly choosen ampltudes an phase shifts.
%
t  = 0:1e-3:2;
sinw=sin(2*pi*this.fmod(:)*t);
cosw=cos(2*pi*this.fmod(:)*t);
N = 10;
minr = zeros(1,N);
maxr = zeros(1,N);
nf = length(this.fmod);
for j=1:N
  a  = gaussrnd(0,this.var,1,nf);
  b  = gaussrnd(0,this.var,1,nf);

  r=sum(repmat(a(:),[1 length(t)]).*cosw+...
        repmat(b(:),[1 length(t)]).*sinw,1);

  minr(j)=min(r);
  maxr(j)=max(r);
end

this.A = 1/(max(maxr)-min(minr)); % A*r(t) has a range of approx. [-0.5 0.5] 
this.B = 0.5;                       % A*r(t)+B has a range of approx. [0.0,1.0]
