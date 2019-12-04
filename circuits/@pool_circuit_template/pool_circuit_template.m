function this = pool_circuit_template(varargin)
%POOL_CIRCUIT_TEMPLATE generates a pool circuit template.
%   CT = POOL_CIRCUIT_TEMPLATE generates an empty pool circuit template.
%
%   CT = POOL_CIRCUIT_TEMPLATE('PropertyName1',PropertyValue1,'PropertyName2',...)
%   additional sets the value of the specified properties.
%
%   CT = POOL_CIRCUIT_TEMPLATE(N) generates a pool circuit template containing
%   the pool circuit templates with name N from the internal library, e.g. 'C17'.
%   (N shouldn't be a property name.)
%
%   CT = POOL_CIRCUIT_TEMPLATE(N1,N2,...) generates a cell array of pool circuit templates
%   objects containing the pool circuit templates with the names N1, N2, ...
%   from the internal library, e.g. 'C17'. (N1 shouldn't be a property name.)
%
%   CT = POOL_CIRCUIT_TEMPLATE('all') generates a cell array of pool circuit templates
%   objects containing all pool circuit templates from the internal library.
%
%
%   See also POOL_CIRCUIT_TEMPLATE/GENERATE
%            POOL_CIRCUIT_TEMPLATE/PLOT
%            POOL_CIRCUIT_TEMPLATE/VISUALIZE
%            POOL_CIRCUIT_TEMPLATE/ADJUST
%
%   Author: Stefan Haeusler, 3/2003, haeusler@igi.tu-graz.ac.at


% analyse what kind of input arguments
%-------------------------------------

public_properties = { 'name' 'circuit' 'pool' 'conn' 'input' 'INidx' 'OUTidx' 'recorder' 'dt_sim' 'randSeedConn'};

str = [];
for i = 1:nargin
   str{i} = class(varargin{i});
end


MODE = 1; % property assignment

if nargin
 % all argins are of class 'char' and not public_property names -> MODE 2
 if (length(strmatch('char',str,'exact')) == nargin) & ...
   isempty(strmatch(varargin{1},public_properties,'exact'))
   MODE = 2; % load a predefined circuit templates.
 end
end

% create object
%--------------

[dummy,name]=fileparts(mfilename); ii=find(name==filesep); if ~isempty(ii), name=name(ii(end)+1:end); end

switch MODE
   case 1
        % empty object

        this = empty_object(public_properties);
	name=mfilename; ii=find(name==filesep); if ~isempty(ii), name=name(ii(end)+1:end); end
	if nargin == 0
	  this = class(this,name);
	elseif isa(varargin{1},name)
	  this = varargin{1};
	else
	  this = class(this,name);
	  this = set(this,varargin{:});
	end
   case 2
        % load predefined circuit templates
        load('private/CT.mat','CT')
        for i = 1:length(CT)
           names{i} = get(CT{i},'name');
        end

	circuit_names{1:nargin} = varargin{:};

	if (nargin==1) & strcmp(circuit_names{1},'all')
	   circuit_names = names;
	end


        if length(circuit_names) == 1
              j = strmatch(circuit_names{1},names,'exact');
              if isempty(j)
                 errstr = sprintf('Invalid pool circuit template name ''%s''.',circuit_names{1});
                 error(errstr);
              else
                 this = CT{j};
              end
        else
           for i = 1:length(circuit_names)
              j = strmatch(circuit_names{i},names,'exact');
              if isempty(j)
                 errstr = sprintf('Invalid pool circuit template name ''%s''.',circuit_names{i});
                 error(errstr);
              else
                 this{i} = CT{j};
              end
           end
        end
end

function this = empty_object(public_properties);
	this.description = 'generates a pool circuit from a pool circuit template';

	this.name = 'PC0';
	this.name_comment = 'name of the pool circuit template';

	this.circuit = 'balanced_fanin_circuit';
	this.circuit_comment = 'circuit class';

	this.pool.parameters = [];		% obligatory
	this.pool.add.Pool = [];		% obligatory
	this.pool.add.origin = [];		% obligatory
	this.pool_comment = 'pool parameters';

	this.conn.parameters = [];	% obligatory
	this.conn.add = [];	        % obligatory (last field could also be 'faninConn')
	this.conn_comment = 'pool connection parameters';

	this.input.parameters = [];	% obligatory
	this.input.add = [];	% obligatory (last field could also be 'faninConn')
	this.input_comment = 'input connection parameters';

	this.INidx = [];
	this.INidx_comment = 'pool index of each input channel';

	this.OUTidx = [];
	this.OUTidx_comment = 'pool index of each ouput channel';

	this.recorder.dt = 1e-3;
	this.recorder.Tprealloc = 1.0;
	this.recorder.Field = 'spikes';
	this.recorder_comment = 'recorder parameters';

	this.dt_sim = 0.0002;
	this.dt_sim_comment = 'simulation time step [s]';

        rand('state',sum(100*clock))
	this.randSeedConn = randseed;
	this.randSeedConn_comment = 'random seed for the random connections';

	this.public_properties = public_properties;
