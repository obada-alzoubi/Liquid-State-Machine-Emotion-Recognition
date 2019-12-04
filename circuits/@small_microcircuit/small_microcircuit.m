function this = small_microcircuit(varargin)
%SMALL_MICROCIRCUIT generates a small_microcircuit object.
%   CT = SMALL_MICROCIRCUIT generates an empty small_microcircuit object.
%
%   CT = SMALL_MICROCIRCUIT('PropertyName1',PropertyValue1,'PropertyName2',...)
%   additional sets the value of the specified properties.
%
%   CT = SMALL_MICROCIRCUIT(N) generates a small_microcircuit objects containing
%   the small microcircuits with name N from the internal library, e.g. 'C17'.
%   (N shouldn't be a property name.)
%
%   CT = SMALL_MICROCIRCUIT(N1,N2,...) generates a cell array of small_microcircuit
%   objects containing the small microcircuits with the names N1, N2, ... from the
%   internal library, e.g. 'C17'. (N1 shouldn't be a property name.)
%
%   CT = SMALL_MICROCIRCUIT('all') generates a cell array of small_microcircuit
%   objects containing all small microcircuits from the internal library.
%
%   CT = SMALL_MICROCIRCUIT(E) converts a microcircuit E that was exported from the
%   function CSIM with the command E = CSIM('export') into a small_microcircuit 
%   object CT. CT.INidx, CT.OUTidx, CT.Name and the CT.*_std fields receive default
%   values. Additional the microcircuit is generated with the function CSIM and 
%   remains after the function call in the working memory so that it could be 
%   simulated with CSIM('simulate',Tmax,Input).
%
%   CT = SMALL_MICROCIRCUIT(E1,E2,...) generates a cell array of small_microcircuit
%   objects containing conversions of the microcircuits E1,E2,... that were exported
%   from the function CSIM. The last microcircuit remains in the working memory and 
%   could be simulated with CSIM('simulate',Tmax,Input).
%
%
%   CT = SMALL_MICROCIRCUIT(NAME,N,S,PAR) generates a single small microcircuit with 
%   parameters
% 
%  	 NAME ... name of the small microcircuit template, e.g. 'C1'
%	 N    ... array of neuron type specifications, e.g. [EXZ INH EXZ ...]
%	 S    ... matrix, where each row 
%
%			[POST PRE SYN_TYPE A U D F STD]
%
% 		  defines a synaptic connection. POST and PRE are neuron
%		  indices refering to the neuron array N, SYN_TYPE is an 
%		  element of the set {EE,IEd,IEf,F1,F2,F3} and A, U, D and F
%                 are synaptic parameters. STD is defined as 
%		  [std_a std_udf std_delay].
%
%		  If A, U, D or F are NaN then the values of the specified synapse
%		  type defined in PAR.CONN are used.
%
%   	PAR   ... default parameters for the neurons and synapses generated with
%		  ALL_DEFAULT_PARAMETERS.
%
%
%   See also SMALL_MICROCIRCUIT/GENERATE, SMALL_MICROCIRCUIT/PLOT,
%            SMALL_MICROCIRCUIT/VISUALIZE, SMALL_MICROCIRCUIT/ADJUST
%
%   Author: Stefan Haeusler, 10/2002, haeusler@igi.tu-graz.ac.at


% analyse what kind of input arguments
%-------------------------------------

public_properties = { 'name' 'neuron' 'neuron_std' 'synapse' 'synapse_std' 'INidx' 'OUTidx' 'Ascale'};

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

 % exactly 4 argins with the correct class types -> MODE 3
 if nargin == 4
   if ~isempty(strmatch('char',str{1},'exact'))&...
      ~isempty(strmatch('double',str{2},'exact'))&...
      ~isempty(strmatch('double',str{3},'exact'))&...
      ~isempty(strmatch('struct',str{4},'exact'))
      MODE = 3; % generate new circuit
   end
 end

 % all argins are of class 'struct' and have the fieldnames of csim exports -> MODE 4
 if (length(strmatch('struct',str,'exact')) == nargin)
    for i = 1:nargin
       n = fieldnames(varargin{i});
       fn{i} = [n{:}];
    end
    fn_csim = 'globalsobjectdstsrcrecorderInfoversion'; % fieldnames of a csim export structure
    if (length(strmatch(fn_csim,fn,'exact')) == nargin)
       MODE = 4; % convert csim export circuits
    end
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
           names{i} = CT{i}.name;
        end

	circuit_names{1:nargin} = varargin{:};

	if (nargin==1) & strcmp(circuit_names{1},'all')
	   circuit_names = names;
	end


        if length(circuit_names) == 1
              j = strmatch(circuit_names{1},names,'exact');
              if isempty(j)
                 errstr = sprintf('Invalid small microcircuit template name ''%s''.',circuit_names{1});
                 error(errstr);
              else
                 this = CT{j};
              end
        else
           for i = 1:length(circuit_names)
              j = strmatch(circuit_names{i},names,'exact');
              if isempty(j)
                 errstr = sprintf('Invalid small microcircuit template name ''%s''.',circuit_names{i});
                 error(errstr);
              else
                 this{i} = CT{j};
              end
           end
        end
   case 3
        % generate a specific circuit
        this = empty_object(public_properties);
        this = gen_circ_temp(this,varargin{:});
        this = class(this,name);
   case 4
        % convert csim exports

        if nargin == 1
           this = empty_object(public_properties);
           this = conv_circ_temp(this,varargin{i});
           this = class(this,name);
        else
           for i = 1:nargin
              this{i} = empty_object(public_properties);
              this{i} = conv_circ_temp(this{i},varargin{i});
              this{i} = class(this{i},name);
   	      this{i}.name = sprintf('CE%i',i);
           end
        end
end

function this = empty_object(public_properties);
	this.description = 'generates a small microcircuit from a microcircuit template';

	this.name = 'C0';
	this.name_comment = 'name of the small microcircuit';

	this.neuron.spec = [];
	this.neuron.type = [];
	this.neuron.Vm_thresh = [];
	this.neuron.Vm_reset = [];
	this.neuron.Vm_init = [];
	this.neuron.Vm_rest = [];
	this.neuron.Abs_refr = [];
	this.neuron.Cm = [];
	this.neuron.Rm = [];
	this.neuron.I_base = [];
	this.neuron.Noise = [];
	this.neuron_comment = 'neuron parameters';
	
	this.neuron_std.Vm_thresh = [];
	this.neuron_std.Vm_reset = [];
	this.neuron_std.Vm_init = [];
	this.neuron_std.Vm_rest = [];
	this.neuron_std.Abs_refr = [];
	this.neuron_std.Cm = [];
	this.neuron_std.Rm = [];
	this.neuron_std.I_base = [];
	this.neuron_std.Noise = [];
	this.neuron_std_comment = 'std for neuron parameters';
	
	this.synapse.spec = [];
	this.synapse.type = [];
	this.synapse.Pre_n = [];
	this.synapse.Post_n = [];
	this.synapse.A = [];
	this.synapse.Delay = [];
	this.synapse.Tau = [];
	this.synapse.U = [];
	this.synapse.D = [];
	this.synapse.F = [];
	this.synapse.u_inf = [];
	this.synapse.r_inf = [];
	this.synapse.p = [];
	this.synapse_comment = 'synaptic parameters';

	this.synapse_std.A = [];
	this.synapse_std.Delay = [];
	this.synapse_std.Tau = [];
	this.synapse_std.U = [];
	this.synapse_std.D = [];
	this.synapse_std.F = [];
	this.synapse_std.u_inf = [];
	this.synapse_std.r_inf = [];
	this.synapse_std.p = [];
	this.synapse_std_comment = 'std for synaptic parameters';
	
	this.INidx = [];
	this.INidx_comment = 'input neuron index for each channel';

	this.OUTidx = [];
	this.OUTidx_comment = 'output neuron indices';
	
	this.Ascale = [];
	this.Ascale_comment = 'scale of synaptic strength A';
	
	this.public_properties = public_properties;

