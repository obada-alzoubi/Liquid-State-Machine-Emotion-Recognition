function [IT] = generate_IT(varargin)
%GENERATE_IT generates a fixed set of at least 12 input templates.
%   IT = GENERATE_IT returns an analog_signal object IT consisting of a fixed
%   set of 12 analog input templates normalized to [0,1] A.
%
%   IT = GENERATE_IT(FILENAME,IDX) adds additional input templates consisting of single
%   PSC traces with indices IDX and a fixed combination of 10 and 100 PSC traces. The data 
%   of the PSC traces of a network of at least 100 neurons must be stored in the file 
%   FILENAME in the output format of csim_lifnet.
%
%
%   See also ANALOG_INPUT_SET/GENERATE
%
%   Author: Stefan Haeusler, 10/2002, haeusler@igi.tu-graz.ac.at

additional_definitions

Tmax = 1.0;
dt = 1e-3;
nI = ceil(Tmax/dt);

IT = analog_input_set;

ind = 1;

% single step

IT = set(IT,'channel',{ind},'name','I1');
IT = set(IT,'channel',{ind},'dt',dt);
IT = set(IT,'channel',{ind},'data',[zeros(1,nI/4) ones(1,nI/2) zeros(1,nI/4)]);
ind = ind + 1;

% double step

IT = set(IT,'channel',{ind},'name','I2');
IT = set(IT,'channel',{ind},'dt',dt);
IT = set(IT,'channel',{ind},'data',[zeros(1,nI/5) ones(1,nI/5) zeros(1,nI/5) ones(1,nI/5) zeros(1,nI/5)]);
ind = ind + 1;

% little steps

data = zeros(1,nI);
i = ceil( [ nI/16*1:nI/16*2 nI/16*3:nI/16*4 nI/16*5:nI/16*6 nI/16*11:nI/16*12 ] );
data(i) = ones(size(i));

IT = set(IT,'channel',{ind},'name','I3');
IT = set(IT,'channel',{ind},'dt',dt);
IT = set(IT,'channel',{ind},'data',data);
ind = ind + 1;

% increasing triple steps

data = [zeros(1,ceil(nI/7)) 1/3*ones(1,ceil(nI/7)) ...
	      zeros(1,ceil(nI/7)) 2/3*ones(1,ceil(nI/7)) ...
	      zeros(1,ceil(nI/7)) ones(1,ceil(nI/7)) ...
	      zeros(1,ceil(nI/7))];

IT = set(IT,'channel',{ind},'name','I4');
IT = set(IT,'channel',{ind},'dt',dt);
IT = set(IT,'channel',{ind},'data',data);
ind = ind + 1;


% decreasing steps

data = [zeros(1,ceil(nI/7)) ones(1,ceil(nI/7)) ...
	      zeros(1,ceil(nI/7)) 2/3*ones(1,ceil(nI/7)) ...
	      zeros(1,ceil(nI/7)) 1/3*ones(1,ceil(nI/7)) ...
	      zeros(1,ceil(nI/7))];

IT = set(IT,'channel',{ind},'name','I5');
IT = set(IT,'channel',{ind},'dt',dt);
IT = set(IT,'channel',{ind},'data',data);
ind = ind + 1;

% increasing ramp

IT = set(IT,'channel',{ind},'name','I6');
IT = set(IT,'channel',{ind},'dt',dt);
IT = set(IT,'channel',{ind},'data',[zeros(1,nI/8) [1:3*nI/8]/(3*nI/8) zeros(1,nI/2)]);
ind = ind + 1;

% decreasing ramp

IT = set(IT,'channel',{ind},'name','I7');
IT = set(IT,'channel',{ind},'dt',dt);
IT = set(IT,'channel',{ind},'data',[zeros(1,nI/8) [3*nI/8:-1:1]/(3*nI/8) zeros(1,nI/2)]);
ind = ind + 1;

% double ramp

IT = set(IT,'channel',{ind},'name','I8');
IT = set(IT,'channel',{ind},'dt',dt);
IT = set(IT,'channel',{ind},'data',[zeros(1,nI/8) [1:3*nI/8]/(3*nI/8) [3*nI/8:-1:1]/(3*nI/8) zeros(1,nI/8)]);
ind = ind + 1;

% one wave

IT = set(IT,'channel',{ind},'name','I9');
IT = set(IT,'channel',{ind},'dt',dt);
IT = set(IT,'channel',{ind},'data',[0.5 + 0.5*sin([1:nI]/nI *2*pi)]);
ind = ind + 1;


% three waves

IT = set(IT,'channel',{ind},'name','I10');
IT = set(IT,'channel',{ind},'dt',dt);
IT = set(IT,'channel',{ind},'data',[0.5 + 0.5*sin([1:nI]/nI *6*pi)]);
ind = ind + 1;


% wave superposition (all dPhi = 0)

data = [1:nI]/nI *2*pi;
m = [1 2 3 5 9];
data = rand(size(m))*sin(m'*data);
data = data - min(data);
data = data/max(data);

IT = set(IT,'channel',{ind},'name','I11');
IT = set(IT,'channel',{ind},'dt',dt);
IT = set(IT,'channel',{ind},'data',data);
ind = ind + 1;


% increasing frequency wave

IT = set(IT,'channel',{ind},'name','I12');
IT = set(IT,'channel',{ind},'dt',dt);
IT = set(IT,'channel',{ind},'data',[0.5 + 0.5*sin( ([1:nI]/nI + cumsum([1:nI]/nI/300).^2 )*2*pi)]);
ind = ind + 1;


if nargin > 1
   load(varargin{1})
   X = data.X;

   % membran voltages of 1 in a circuit of 135 neurons

   I = varargin{2};
   for nI = 1:length(I)

      data = X(I(nI),:);
      data = data/max(data)*1.25;

      IT = set(IT,'channel',{ind},'name',sprintf('I%i',ind));
      IT = set(IT,'channel',{ind},'dt',20e-3);
      IT = set(IT,'channel',{ind},'data',data);
      ind = ind + 1;
   end

   % membran voltage of neuron with 10 synaptic inputs

   data = sum(X(1:10,:),1);
%   data = rand(1,10)*X(ceil(size(X,1)*rand(1,10)),:);
   data = data/max(data);

   IT = set(IT,'channel',{ind},'name',sprintf('I%i',ind));
   IT = set(IT,'channel',{ind},'dt',20e-3);
   IT = set(IT,'channel',{ind},'data',data);
   ind = ind + 1;


   % membran voltage of neuron with 100 synaptic inputs

   data = sum(X(1:100,:),1);
%   data = rand(1,100)*X(ceil(size(X,1)*rand(1,100)),:);
   data = data/max(data);

   IT = set(IT,'channel',{ind},'name',sprintf('I%i',ind));
   IT = set(IT,'channel',{ind},'dt',20e-3);
   IT = set(IT,'channel',{ind},'data',data);
   ind = ind + 1;
end
