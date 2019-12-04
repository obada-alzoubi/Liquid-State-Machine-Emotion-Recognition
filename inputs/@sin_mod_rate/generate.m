function stimulus = generate(this,Tmax,varargin)
% SIM_MOD_RATE/GENERTAE A call to the function returns one instance 
%   of an input defined by the distribution 'sin_mod_rate'.
% 
%  I = generate(smr) returns a structure 'I' with the following elements
%    I.r  ... the modulated rate used to generate the spike trains
%    I.t  ... the time base for I.r; e.g. use plot(I.t,I.r) to make
%             a plot of the actual choosen modulated rate r(t).
%    I.st ... a cell array of length 'd'. Each member 'I.st{j}' (j=1...d)
%             is a simple double array with the spike times of input spike
%             train j.
%
%  Example: create a sin_mod_rate object called smr with d=5 and Tmax=1.0
%     and generate a single randomly drawn instance and plot it:
% 
%       smr = sin_mod_rate('d',5,'Tmax',1.0);
%       I = generate(smr);
%       plot_instance(smr,I);
%
%  See also: SIN_MOD_RATE/INIT, SIN_MOD_RATE/GENERATE, SIN_MOD_RATE/PLOT_INSTANCE
%
%  Author: Thomas Natschlaeger, 11/2001, tnatschl@igi.tu-graz.ac.at
% 
%
% calcuate the modulated rate r(t) as the sum of sin waves with
% randomly choosen ampltudes an phase shifts.
%

if nargin < 2, Tmax = -1; end

if this.Tstim > -1, Tstim=this.Tstim; else Tstim=Tmax; end

if Tstim < 0
  error('Tstim undefined!');
end

nf = length(this.fmod);
a  = gaussrnd(0,this.var,1,nf); % randomly choose amplitudes of modulating frequencies    
b  = gaussrnd(0,this.var,1,nf); % from a normal distribution with zero mean and a given variance (default: 'this.var==1').

dt=1e-3;

t  = 0:dt:Tstim;
w=2*pi*this.fmod(:)*t;
r=sum(repmat(a(:),[1 length(t)]).*cos(w)+...
      repmat(b(:),[1 length(t)]).*sin(w),1);

r  = this.A * r + this.B;       % apply scale and offset such that 0<= r(t) <= 1 for all t
                                % 'this.A' and 'this.B' are determined in '@sim_mod_rate/private/init.m'.
	
r  = this.fmax*max(min(r,1),0);           % definitely restrict r into the range [0,1]

spike_trains = rate2spikes(r,dt,this.nChannels);

[stimulus.channel(1:this.nChannels).data]=deal(spike_trains{:});
[stimulus.channel.spiking] = deal(1);
[stimulus.channel.dt]      = deal(-1);

stimulus.info(1).Tstim = Tstim;
stimulus.info(1).r     = r;
stimulus.info(1).dt    = dt;
