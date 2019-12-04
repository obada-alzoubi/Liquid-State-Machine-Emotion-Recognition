function S=generate(this,argTstim,varargin)

if nargin < 2, argTstim = -1; end

if this.Tstim > -1, Tstim=this.Tstim; else Tstim=argTstim; end

if Tstim <= 0
  error('length of stimulus undefined!');
end

%
% generate constant r(t)
%
dt=1e-3;
t=[0      Tstim ];
r=[this.f this.f];
r=interp1(t,r,0:dt:Tstim,'nearest');

%
% convert time varying rate to this.nChannels spike trains 
%
spikes=rate2spikes(r,dt,this.nChannels,Tstim);

%
% convert to stimulus format
%
[S.channel(1:this.nChannels).data] = deal(spikes{:});
[S.channel.spiking]                = deal(1);
[S.channel.dt]                     = deal(-1);


S.info(1).Tstim  = Tstim;
S.info(1).r      = r;
S.info(1).dt     = dt;
