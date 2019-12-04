function this = sim_mod_rate(varargin)
% SIN_MOD_RATE/SIN_MOD_RATE Constructor for the input distribution class 'sim_mod_rate'.
%
%   this = sim_mod_rate; creates a default 'sim_mod_rate' object.
%
%   this = sim_mod_rate(p1,v1,p2,v2,...); creates a  'sim_mod_rate' object
%      with the specific values v1,v2, ... for the properties p1,p2,...
%      where valid properties are (default values in brakets)
%      'd'     ... the number of spike trains [4]
%      'Tmax'  ... the lenght of the spike trains [0.5sec]
%      'f_max' ... maximal frequency of a spike train [100Hz]
%      'f_mod' ... the modulating frequnecies [1 2 3 5 9 Hz]
%      'var'   ... variance of amplitudes of modulating frequencies [1.0]
%
%  Description: The 'sim_mod_rate' distribution generates 'd' Poisson
%      spike trains (of length 'Tmax') with a modulated rate
%      'f_max'*r(t).  The rate r(t) is a random signal where the
%      amplitudes of its frequency components (defined by 'f_mod') are
%      drawn from a Gaussion with zero mean and a variance of
%      'var'. This implementation tries to scale r(t) into the range
%      [0,1] (if the scaling fails r(t) is clipped to [0,1]). Thus the
%      maximal frequency of a spike train is 'f_max'.
% 
%  Example: create a sin_mod_rate object called this with d=5 and Tmax=1.0
% 
%    this = sin_mod_rate('d',5,'Tmax',1.0);
%
%  See also: SIN_MOD_RATE/INIT, SIN_MOD_RATE/GENERATE, SIN_MOD_RATE/PLOT_INSTANCE
%
%  Author: Thomas Natschlaeger, 11/2001, tnatschl@igi.tu-graz.ac.at
%


this.description = 'sin-wave modulated Poisson spike trains';

this.nChannels         = 4;           
this.nChannels_comment = 'number of input spike trains';

this.Tstim         = -1;
this.Tstim_comment = 'length of stimulus (-1 ... length determined by call to generate)';

this.fmax         = 100;         
this.fmax_comment = 'maximal frequency [Hz] of a spike train';

this.fmod         = 1:2:100; 
this.fmod_comment = 'The vector of modulating frequencies';

this.var          = 1.0;         
this.var_comment  = 'variance of amplitudes of modulating frequencies';

this.A            = 0;           
this.A_comment    = 'A and B are used to scale r(t) such that';

this.B            = 0.5;           
this.B_comment    = '0 <= r(t) <= 1 for each time t';


this.public_properties = { 'nChannels' 'Tstim' 'fmax' 'fmod' 'var' };

[pathstr,name,ext,versn] = fileparts(mfilename);
if nargin == 0
  this = class(this,name);
elseif isa(varargin{1},name)
  this = varargin{1};
else
  this = class(this,name);
  this = set(this,varargin{:});
end

this=estimateAB(this);
