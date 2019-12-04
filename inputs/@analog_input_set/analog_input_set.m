function this = analog_input_set(varargin)
%ANALOG_INPUT_SET generates an analog input set object.
%   IT =  generates an empty analog_input_set object.
%
%   IT = ANALOG_INPUT_SET('PropertyName1',PropertyValue1,'PropertyName2',...)
%   additional sets the value of the specified properties.
%
%   IT = ANALOG_INPUT_SET(N) generates an analog_input_set object containing
%   the analog input with name N from the internal library, e.g. 'I3'.
%   (N shouldn't be a property name.)
%
%   IT = ANALOG_INPUT_SET(N1,N2,...) generates an analog_input_set object
%   containing the analog inputs with the names N1, N2, ... from the internal
%   library. (N1 shouldn't be a property name.)
%
%   IT = ANALOG_INPUT_SET('all') generates an analog_input_set object
%   containing all analog inputs from the internal library. 
%
%
%   See also ANALOG_INPUT_SET/GENERATE, ANALOG_INPUT_SET/PLOT,
%            ANALOG_INPUT_SET/PLOT_INSTANCE
%
%   Author: Stefan Haeusler, 10/2002, haeusler@igi.tu-graz.ac.at

% analyse what kind of input arguments
%-------------------------------------

public_properties =  {'name' 'channel' 'nChannels'};

str = [];
for i = 1:nargin
   str{i} = class(varargin{i});
end


MODE = 1; % property assignment

if nargin

 % all argins are of class 'char' and not public_property names -> MODE 2
 if (length(strmatch('char',str,'exact')) == nargin) & ...
   isempty(strmatch(varargin{1},public_properties,'exact'))
   MODE = 2; % load a predefined input templates.
 end
end

% create object
%--------------

[dummy,name]=fileparts(mfilename); ii=find(name==filesep); if ~isempty(ii), name=name(ii(end)+1:end); end

switch MODE
   case 1
        % empty object

        this = empty_object(public_properties);

	if nargin == 0
	  this = class(this,name);
	elseif isa(varargin{1},name)
	  this = varargin{1};
	else
	  this = class(this,name);
	  this = set(this,varargin{:});
	end
   case 2
        % load predefined input templates

	load('private/IT.mat','IT')
        for i = 1:length(IT.channel)
           names{i} = IT.channel(i).name;
        end

        this = empty_object(public_properties);

	input_names = varargin;

	if (nargin==1) & strcmp(input_names{1},'all')
	   input_names = names;
	end

        for i = 1:length(input_names)
           j = strmatch(input_names{i},names,'exact');
           if isempty(j)
              errstr = sprintf('Invalid analog input template name ''%s''.',input_names{i});
              error(errstr);
           else
               this.channel(i) = IT.channel(j);
           end
        end

	this.nChannels = length(input_names);
	this = class(this,name);
end

function this = empty_object(public_properties);
	this.description       = 'generates analog input stimuli from a fixed set of input templates';

        this.nChannels         = 0;
        this.nChannels_comment = 'number of analog channels';

	this.name = ['Input templates ' datestr(clock,0)];
	this.name_comment = 'name of the input template set';

	this.channel.name = 'empty';
	this.channel.data = [];
	this.channel.dt = [];
	this.channel_comment = 'data of analog input templates';

	this.public_properties = public_properties;

