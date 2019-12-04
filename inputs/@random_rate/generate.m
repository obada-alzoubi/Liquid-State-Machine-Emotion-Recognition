function S=generate(this,argTstim,varargin)
%@random_rate/generate generates spike trains with a random drawn rate.
%
%   Syntax
%
%     S=generate(RR)
%     S=generate(RR,Tstim)
%
%   Description
%
%     generate(RR) generates a stimulus according to the random_rate
%     input distribution object RR.
%  
%     S=generate(RR) returns the struct array S containing the
%     stimulus instance. The length of the stimulus is determined by
%     RR.Tstim.
%
%     S=generate(RR,Tstim) returns the struct array S containing the
%     stimulus instance. The length of the stimulus is determined by
%     the argument Tstim.
%
%   Algorithm
%
%     1) First a time varying rate r(t) is created randomly in the
%     following way: in each interval of length RR.binwidth a rate r
%     is uniformly drawn from the interval [0,RR.fmax].
%
%     2) If RR.nRates is not set to Inf this rate r is rounded such
%     that at most RR.nRates can occur (including RR.fmax, excluding
%     0).
%
%     3) RR.nChannels Poisson spike trains with the time varying rate
%     r(t) are created.
%     
%   Example
%
%      The following code fragment shows hoe to create a random_rate
%      input distribution object RR and then plots one particular
%      stimulus S.
%
%        >> RR = random_rate('nChannels',4,'fmax',80);
%        >> S = generate(RR,2.0); 
%        >> plot(RR,S);
%  
%   See Also
%
%     empty_stimulus, @random_rate/random_rate, @random_rate/plot,
%     @random_rate/private/rand_rate

%   Author:  Thomas Natschlaeger, Oct. 2002, tnatschl@igi.tu-graz.ac.at
%   $Author: tnatschl $, $Date: 2003/02/20 07:19:39 $, $Revision: 1.3 $
%   $Cross-References$

if nargin < 2, argTstim = -1; end

if this.Tstim > -1, Tstim=this.Tstim; else Tstim=argTstim; end

if Tstim <= 0
  error('length of stimulus undefined!');
end

%
% generate random r(t)
%
[r,dt]=rand_rate(this,Tstim);

%
% convert time varying rate to this.nChannels spike trains 
%
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
