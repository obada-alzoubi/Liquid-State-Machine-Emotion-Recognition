function stimulus = generate(this,TSTIM,ITnames,varargin)
%GENERATE   generates an analog input stimulus from analog input templates.
%   S = GENERATE(IT) generates a stimulus from the input template set IT.
%   The stimulus consists of all templates of the template set IT, wheres template
%   1 is injected in channel 1, template 2 in channel 2 etc.
%
%   S = GENERATE(IT,TSTIM) generates a stimulus of length TSTIM.
%
%   S = GENERATE(IT,TSTIM,IT_NAMES) generates a stimulus that consists only of
%   input templates specified in the cell array IT_NAMES. The returned structure
%   S has the following elements.
%
%   S.info.name    ... name of the input stimulus
%   S.info.IT_name ... name of the input template set
%   S.info.Tstim   ... length of time of the analog input stimulus
%
%   S.channel      ... a struct array of length 'd'. Each member 'S.channel(j)' (j=1...d)
%                      contains the data of one input channel with the fields:
%
%			data		...	double array with the input signal data
%			spiking		...	0 (indicates non-spiking input)
%			idx		...	input channel index
%			ITidx		...	input template index
%			name		...     input template name
%			trans		...     struct array of input transformation
%						parameters with the fields:
%
%						op       ... name TRANS_OP
%						mean     ... MEAN of the gauss dist.
%						std	 ... STD of the gauss dist.
%						dt_noise ... DT_NOISE
%						arg      ... double array with the
%						   	     actual drawn parameters
%						unit     ... 'sec','A' and ''
%
%   S = GENERATE(IT,TSTIM,IT_NAMES,TRANS_OP,[M1 M2 ...],[SD1 SD2 ...],...)
%   additional performs the transformation TRANS_OP on each input template. The
%   parameters for the transformation of each input template are drawn from a gauss
%   distribution with mean M1, M2 etc. and standard deviation SD1, SD2 etc.
%   respectively. The number of means and stds equals the number of input templates.
%
%       TRANS_OP:
%
%	'shift'		...	time shift
%	'offset'	...	set uniform offset
%	'amplify'	...	amplify uniform
%	'noisy offset'	...	set offset with noise
%	'noisy amplify'	...	amplify with noise
%	'scale time'	...	scale time steps uniform
%	'interpolate'	...	interpolates signals
%	'rw scale time' ...	scale time steps via random walk
%	'rw amplify'	...	amplify via random walk
%
%       (for multiple transformations take care of the order)
%
%   For the transformation 'noisy offset' and 'noisy amplify' an additional
%   parameter DT_NOISE must be specified:
%
%   S = GENERATE(IT,TSTIM,IT_NAMES,TRANS_OP,[M1 M2 ...],[SD1 SD2 ...],DT_NOISE,...)
%
%   DT_NOISE defines the time base for the noise.
%
%   Example:   S{1} = generate(IT,{'I3' 'I4'},[1 3],...
%                      'amplify',[2e-3 2e-3],[0 0],...
%                      'noisy offset',[13.5e-3 14e-3],[2e-4 1e-4],1e-4);
%
%
%   See also ANALOG_INPUT_SET/PLOT_INSTANCE, ANALOG_INPUT_SET/PLOT,
%	     ANALOG_INPUT_SET/ANALOG_INPUT_SET
%
%   Author: Stefan Haeusler, 10/2002, haeusler@igi.tu-graz.ac.at

% check input arguments
%----------------------

if nargin < 3
   ITnames = {this.channel.name};
end

INidx = 1:length(ITnames);

if ~isnumeric(TSTIM)
   error('Argument for the stimulus length TSTIM must be of class ''double''.')
end

if ~all(size(TSTIM)==[1 1])
   error('Argument for the stimulus length TSTIM must have only one element.')
end

if ~iscell(ITnames)
   error('Argument for the input template names IT_NAMES must be of class ''cell''.')
end

for i = 1:length(ITnames)
   str{i} = class(ITnames{i});
end

if length(strmatch('char',str,'exact')) ~= length(ITnames);
   error('Elements of the input template names cell array IT_NAMES must be of class ''char''.')
end

if size(ITnames,1) ~= 1
   error('Argument for the input template names IT_NAMES must have only one row.')
end


if isempty(strmatch('double',class(INidx),'exact'))
   error('Argument for the input neuron index IDX must be of class ''double''.')
end

if length(ITnames)~=length(INidx)
   error('Matrix dimensions of the arguments IT_NAMES and IDX must agree.')
end

if size(INidx,1) ~= 1
   error('Argument for the input neuron index IDX must have only one row.')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IT = this.channel;

% get all input template names
Tstim = [];
for i = 1:length(IT)
   ITAllNames{i} = IT(i).name;
   ITNameIdx = strcmp(ITAllNames{i},ITnames);
   if any(ITNameIdx)
      Tstim(end+1) = length(IT(i).data)*IT(i).dt;
%      Tstim(end+1) = (length(IT(i).data)-1)*IT(i).dt;
   end
end


if (nargin > 1)&&~isempty(TSTIM)
   Tstim = TSTIM;
else
   Tstim = max(Tstim);
end

stimulus.info.name = deblank(sprintf('%s ',ITnames{:}));
stimulus.info.IT_name = this.name;
stimulus.info.Tstim = max(Tstim);


% copy input data
for i = 1:length(ITnames)
   j = strmatch(ITnames{i},ITAllNames,'exact');

   % check if input template name is valid
   if isempty(j)
      error(sprintf('Input template ''%s'' not found.',ITnames{i}));
   end

   % standard parameters
   stimulus.channel(i).dt = IT(j).dt;
   stimulus.channel(i).data = IT(j).data;
   stimulus.channel(i).spiking = 0;
   stimulus.channel(i).idx = INidx(i);

   % extra parameters
   stimulus.channel(i).trans = [];
   stimulus.channel(i).ITidx = j;
   stimulus.channel(i).name = ITnames{i};
end

fprintf('Generate input from templates [')
fprintf('%s ',stimulus.channel.name)
fprintf('\b].\n')

% addition input arguments are transformation parameter

i = 1;
% at least three more arguments must be specified to continue
while (i <= nargin-5)

   % check class 'double'
   if isempty(strmatch('double',class(varargin{i+1}),'exact'))
      error('Argument for the means M1,... must be of class ''double''.')
   end

   % check class 'double'
   if isempty(strmatch('double',class(varargin{i+2}),'exact'))
      error('Argument for the std SD1,... must be of class ''double''.')
   end

   % check if number of means and stds is correct
   if (length(varargin{i+1})~=length(ITnames))|(length(varargin{i+2})~=length(ITnames) )
      errstr = sprintf(' ''%s'': Number of means and stds must be equal the number of input templates.',varargin{i});
      error(errstr);
   end

   switch varargin{i}
      case {'shift'}
         fprintf('  SHIFT                 with mean [')
	 fprintf('%g ',varargin{i+1})
         fprintf('\b] sec and std [')
	 fprintf('%g ',varargin{i+2})
         fprintf('\b] sec.\n')

         for j = 1:length(varargin{i+1})
            mu = ceil(varargin{i+1}(j)/stimulus.channel(j).dt);
            STD2 = ceil(varargin{i+2}(j)/stimulus.channel(j).dt);
            dx = round(gaussrnd(mu,STD2,1,1));
            stimulus.channel(j).data = circshift(stimulus.channel(j).data,[0 dx]);

            stimulus.channel(j).trans(end+1).op = varargin{i};
            stimulus.channel(j).trans(end).mean = mu;
            stimulus.channel(j).trans(end).std = STD2;
            stimulus.channel(j).trans(end).dt_noise = [];
            stimulus.channel(j).trans(end).arg = dx*stimulus.channel(j).dt;
            stimulus.channel(j).trans(end).unit = '[sec]';
         end
         i = i + 3;
      case {'offset'}
         fprintf('  UNIFORM OFFSET        with mean [')
	 fprintf('%g ',varargin{i+1})
         fprintf('\b] A and std [')
	 fprintf('%g ',varargin{i+2})
         fprintf('\b] A.\n')

         for j = 1:length(varargin{i+1})
            mu = varargin{i+1}(j);
            STD2 = varargin{i+2}(j);
            dy = gaussrnd(mu,STD2,1,1);
            stimulus.channel(j).data = stimulus.channel(j).data + dy;

            stimulus.channel(j).trans(end+1).op = varargin{i};
            stimulus.channel(j).trans(end).mean = mu;
            stimulus.channel(j).trans(end).std = STD2;
            stimulus.channel(j).trans(end).dt_noise = [];
            stimulus.channel(j).trans(end).arg = dy;
            stimulus.channel(j).trans(end).unit = '[A]';
         end
         i = i + 3;
      case {'amplify'}
         fprintf('  UNIFORM AMPLIFICATION with mean [')
	 fprintf('%g ',varargin{i+1})
         fprintf('\b] and std [')
	 fprintf('%g ',varargin{i+2})
         fprintf('\b].\n')

         for j = 1:length(varargin{i+1})
            mu = varargin{i+1}(j);
            STD2 = varargin{i+2}(j);
            a = gaussrnd(mu,STD2,1,1);
            stimulus.channel(j).data = stimulus.channel(j).data*a;

            stimulus.channel(j).trans(end+1).op = varargin{i};
            stimulus.channel(j).trans(end).mean = mu;
            stimulus.channel(j).trans(end).std = STD2;
            stimulus.channel(j).trans(end).dt_noise = [];
            stimulus.channel(j).trans(end).arg = a;
            stimulus.channel(j).trans(end).unit = '';
         end
         i = i + 3;
      case {'noisy offset'}
         if (i == nargin-5)
            errstr = sprintf(' Last argument DT_NOISE for the transformation ''%s'' is missing.',varargin{i});
            error(errstr);
         end

         % check class 'double'
         if isempty(strmatch('double',class(varargin{i+3}),'exact'))
            error('Argument for the noise time base DT_NOISE must be of class ''double''.')
         end

         fprintf('  NOISY OFFSET          with mean [')
	 fprintf('%g ',varargin{i+1})
         fprintf('\b] A and std [')
	 fprintf('%g ',varargin{i+2})
         fprintf('\b] A, dt_noise=%g sec.\n',varargin{i+3})

         for j = 1:length(varargin{i+1})
            mu = varargin{i+1}(j);
            STD2 = varargin{i+2}(j);
            Tmax =  length(stimulus.channel(j).data)*stimulus.channel(j).dt;
            a = gaussrnd(mu,STD2,1,ceil(Tmax/varargin{i+3}));
            aidx = floor(stimulus.channel(j).dt*[0:length(stimulus.channel(j).data)-1]/varargin{i+3})+1;
            stimulus.channel(j).data = stimulus.channel(j).data + a(aidx);

            stimulus.channel(j).trans(end+1).op = varargin{i};
            stimulus.channel(j).trans(end).mean = mu;
            stimulus.channel(j).trans(end).std = STD2;
            stimulus.channel(j).trans(end).dt_noise = varargin{i+3};
            stimulus.channel(j).trans(end).arg(1) = mean(a);
            stimulus.channel(j).trans(end).arg(2) = std(a);
            stimulus.channel(j).trans(end).unit = '[A]';
         end
         i = i + 4;
      case {'noisy amplify'}
         if (i == nargin-5)
            errstr = sprintf(' Last argument DT_NOISE for the transformation ''%s'' is missing.',varargin{i});
            error(errstr);
         end

         fprintf('  NOISY AMPLIFICATION   with mean [')
	 fprintf('%g ',varargin{i+1})
         fprintf('\b] and std [')
	 fprintf('%g ',varargin{i+2})
         fprintf('\b], dt_noise=%g sec.\n',varargin{i+3})
         
	 for j = 1:length(varargin{i+1})
            mu = varargin{i+1}(j);
            STD2 = varargin{i+2}(j);
            Tmax =  length(stimulus.channel(j).data)*stimulus.channel(j).dt;
            a = gaussrnd(mu,STD2,1,ceil(Tmax/varargin{i+3}));
            aidx = floor(stimulus.channel(j).dt*[0:length(stimulus.channel(j).data)-1]/varargin{i+3})+1;
            stimulus.channel(j).data = stimulus.channel(j).data.*a(aidx);

            stimulus.channel(j).trans(end+1).op = varargin{i};
            stimulus.channel(j).trans(end).mean = mu;
            stimulus.channel(j).trans(end).std = STD2;
            stimulus.channel(j).trans(end).dt_noise = varargin{i+3};
            stimulus.channel(j).trans(end).arg(1) = mean(a);
            stimulus.channel(j).trans(end).arg(1) = std(a);
            stimulus.channel(j).trans(end).unit = '';
         end
         i = i + 4;
      case {'scale time'}
         fprintf('  SCALE TIME            with mean [')
	 fprintf('%g ',varargin{i+1})
         fprintf('\b] dt and std [')
	 fprintf('%g ',varargin{i+2})
         fprintf('\b] dt.\n')

         for j = 1:length(varargin{i+1})
            mu = varargin{i+1}(j);
            STD2 = varargin{i+2}(j);
            a = max(gaussrnd(mu,STD2,1,1),0);
            stimulus.channel(j).dt = stimulus.channel(j).dt*a;

            stimulus.channel(j).trans(end+1).op = varargin{i};
            stimulus.channel(j).trans(end).mean = mu;
            stimulus.channel(j).trans(end).std = STD2;
            stimulus.channel(j).trans(end).dt_noise = [];
            stimulus.channel(j).trans(end).arg = stimulus.channel(j).dt;
            stimulus.channel(j).trans(end).unit = '[dt]';
         end
         i = i + 3;
      case {'interpolate'}
         fprintf('  INTERPOLATE            with mean [')
	 fprintf('%g ',varargin{i+1})
         fprintf('\b] s and std [')
	 fprintf('%g ',varargin{i+2})
         fprintf('\b] s.\n')

         for j = 1:length(varargin{i+1})
            mu = varargin{i+1}(j);
            STD2 = varargin{i+2}(j);
            a = max(gaussrnd(mu,STD2,1,1),0);

	    dt = stimulus.channel(j).dt;
	    s_dt = stimulus.channel(j).data;
            s = interp1(cumsum(dt*ones(1,size(s_dt,2)),2),s_dt',a:a:dt*size(s_dt,2));
            s(isnan(s)) = 0;
            stimulus.channel(j).data = s;

            stimulus.channel(j).dt = a;

            stimulus.channel(j).trans(end+1).op = varargin{i};
            stimulus.channel(j).trans(end).mean = mu;
            stimulus.channel(j).trans(end).std = STD2;
            stimulus.channel(j).trans(end).dt_noise = [];
            stimulus.channel(j).trans(end).arg = stimulus.channel(j).dt;
            stimulus.channel(j).trans(end).unit = '[s]';
         end
         i = i + 3;
      case {'rw scale time'}
         fprintf('  RW SCALE TIME         with mean [')
	 fprintf('%g ',varargin{i+1})
         fprintf('\b] dt and std [')
	 fprintf('%g ',varargin{i+2})
         fprintf('\b] dt.\n')

         for j = 1:length(varargin{i+1})
            mu = varargin{i+1}(j);
            STD2 = varargin{i+2}(j);
            dt = abs(gaussrnd(mu,STD2,1,length(stimulus.channel(j).data)));
            ti = cumsum(dt);
            ti = ti/ti(end)*length(stimulus.channel(j).data); % if too long then fit
            ti = round(ti);
	    ti = ti - ti(1) + 1;  % set start of time index to 1
            data = zeros(size(stimulus.channel(j).data));
            data = stimulus.channel(j).data(ti);
            stimulus.channel(j).data = data(1:length(stimulus.channel(j).data));

            stimulus.channel(j).trans(end+1).op = varargin{i};
            stimulus.channel(j).trans(end).mean = mu;
            stimulus.channel(j).trans(end).std = STD2;
            stimulus.channel(j).trans(end).dt_noise = [];
            stimulus.channel(j).trans(end).arg(1) = mean(dt);
            stimulus.channel(j).trans(end).arg(2) = std(dt);
            stimulus.channel(j).trans(end).unit = '[dt]';
         end
         i = i + 3;
      case {'rw amplify'}
         fprintf('  RW AMPLIFICATION      with mean [')
	 fprintf('%g ',varargin{i+1})
         fprintf('\b] and std [')
	 fprintf('%g ',varargin{i+2})
         fprintf('\b].\n')

         for j = 1:length(varargin{i+1})
            mu = varargin{i+1}(j);
            STD2 = varargin{i+2}(j);
            da = gaussrnd(mu,STD2,1,length(stimulus.channel(j).data));
            a = 1 + cumsum(da);
            stimulus.channel(j).data = stimulus.channel(j).data.*a;
            stimulus.channel(j).trans_arg{end+1} = max(da);
            stimulus.channel(j).trans_op{end+1} = varargin{i};

            stimulus.channel(j).trans(end+1).op = varargin{i};
            stimulus.channel(j).trans(end).mean = mu;
            stimulus.channel(j).trans(end).std = STD2;
            stimulus.channel(j).trans(end).dt_noise = [];
            stimulus.channel(j).trans(end).arg(1) = mean(da);
            stimulus.channel(j).trans(end).arg(2) = std(da);
            stimulus.channel(j).trans(end).unit = '';
         end
         i = i + 3;
      otherwise
         error(sprintf('Input transformation ''%s'' unknown.',varargin{i}))
   end                                                                                 
end




