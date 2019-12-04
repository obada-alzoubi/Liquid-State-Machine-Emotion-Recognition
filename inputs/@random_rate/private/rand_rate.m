function [r,dt]=rand_rate(this,Tstim)

dt=1e-3;
tt=0:dt:Tstim;
t=(-this.binwidth/2):this.binwidth:Tstim+this.binwidth;
if this.nRates == Inf
  r=rand(size(t))*this.fmax;
elseif this.nRates > 1
  r=round(rand(size(t))*(this.nRates-1))/(this.nRates-1)*this.fmax;  
else
  r=ones(size(t))*this.fmax;    
end 
r=interp1(t,r,tt,'nearest');
