%DEMO for VISUALIZE.

% general CSIM initialization
%----------------------------

LSMROOT='../../..';  % set LSMROOT to the root directory 

addpath(LSMROOT);             
lsm_startup;               

additional_definitions;

% Notes
%________________________________________________________________________________________________
%
%
% analog_input_set IT:
%---------------------
%
% An input class to generate analog input stimuli. 
%
% These stimuli are used as inputs for the command small_microcircuit/VISUALIZE, which represents
% the response of small microcircuits (see small_microcircuit object) to these
% input stimuli.
%
% 	Steps:	1) create input templates
% 	  	2) generate stimuli from these templates
%		3) create small microcircuit templates
%		4) generate small microcircuits from the templates
%		4) vislualize the circuit responses to the stimuli
%
%
% This input class works like all other input classes.
% First generate an input distribution with properties PROP
%
%	IT = analog_input_set(PROP);
%
% If an object is created with no properties
%
%       IT = analog_input_set;
%
% all properties are empty. In order to know which properties
% could be set type 
%
%       IT = analog_input_set;
%       IT
%
% Some properties are structures and their values are not listet with
% usage of the previous command. To get the values of a structure property
% use the GET command, e.g. get(IT,'channel').
%
% The properties of the object IT could be read or changed with 
%
% 	PropertyValue = get(IT,'PropertyName');
% 	IT = set(IT,'PropertyName',PropertyValue);
%
% If the property is a structur (array) use
%
% 	PropertyValue = get(IT,'PropertyName',{i,j},'field',{k});
% 	IT = set(IT,'PropertyName',{i,j},'field',{k},PropertyValue);
%
% In this case the syntax is the same as of the matlab commands
% GETFIELD and SETFIELD (for further help see   help getfield   or 
% help setfield),
%
%  e.g.
%
%       IT = set(IT,'channel',{1},'name','I1');
%       get(IT,'channel',{1},'name');
%
% Another possibility to create an analog_input_set object is to use the
% internal predefined analog input template library. To load inputs
% with the names 'I1' and 'I4' type
% (see also   help analog_input_set/analog_input_set)
%
%       IT = analog_input_set('I1','I4');
%
%
%
% An input stimuli is generated from this distribution with GENERATE with the properties PROP
% (see also   help analog_input_set/generate)
%
%	S = generate(IT,PROP)   % see example below
%
% and plotted with the PLOT_INSTANCE command
% (see also   help analog_input_set/plot_instance)
%
% 	plot_instance(IT,S)     % see example for different possibilities below
%
% Note additional that the plot and plot_instance commands have the option 'pdf' or 'show pdf'
% to create and view pdf files.
%
% The size of the fonts in the plot is optimized for the pdf files.
% Usually if the size of a matlab figure window is maximized everthing is readable.
%
 

% small_microcircuit object CT:
%------------------------------
%
% Uses the same principles of SET, GET, GENERATE and PLOT as the
% analog_input_object above. 
%
% But it has an additional command VISUALIZE and the constructor
% SMALL_MICROCIRCUIT itself has various options to generate an object.
%
% Further the PLOT_INSTANCE command doesn't exist because the microcircuit
% that is generated is from the same class as the original template.
%
% instead of this PLOT_INSTANCE the command PLOT is used
%
%	plot(CT{[1 14 20]})
% 	C = generate(CT{[1 14 20]});
%       plot(C{:})
%
%       (the circuits C could be different from the templates CT, because their parameters
%        could be drawn from gauss distributions whose std is given in C.neuron_std and
%        C.synapse_std. Type e.g.  get(C({1},'neuron_std')   to get the values.)
%
%
% Note that in the plots with the graphical circuit representations the number of the input
% channel (if a channel is present) that is inject into a neuron is plotted on the neuron.
%
% See also
%
%      help small_microcircuit/generate 
%      help small_microcircuit/plot
%      help small_microcircuit/visualize
%      help small_microcircuit/small_microcircuit

% Now the examples
%___________________________________________________________________________________________


% Four ways to generate small_microcircuit objects
% (see help small_microcircuit/small_microcircuit)
%--------------------------------------------------

way = 3;
switch way
   case 1
      % empty object, that has to be initialized later
      CT = small_microcircuit;
   case 2
      % use the internal predefined circuit library
      CT = small_microcircuit('C1','C2','C3','C4','C5','C6','C7','C8','C9','C10',...
                              'C11','C12','C13','C14','C15','C16','C17','C18','C19','C20','C21');
   case 3
      % generate new circuits
      CT = generate_CT(all_default_parameters);     
   case 4
      % import a small microcircuit from the CSIM simulator,
      % which was exported before with the command CSIM('export')

      % first create a circuit in csim, e.g.      
      CT = small_microcircuit('C11'); 
      generate(CT);

      % then convert the circuit
      CSIM_Export = csim('export');
      CT = small_microcircuit(CSIM_Export);     
end



% generate input templates
%-------------------------

% two ways to generate an analog_input_set object
% (see help analog_input_set/analog_input_set)
%--------------------------------------------------

way = 1;
switch way
   case 1
      % generate new analog input templates
      IT = generate_IT('psc_data.mat',[16 27 59 104]);
   case 2
      % use the internal predefined analog input template library
      IT = analog_input_set('I1','I2','I3','I4','I5','I6','I7','I8','I9','I10',...
                              'I11','I12','I13','I14','I15','I16','I17','I18');
end

% plot input templates

figure(1)
plot(IT)


% generate stimuli from the input templates
%------------------------------------------

% Ech stimuli contains the info to which input channels the templates are injected.
% To which neuron a channel is connected is specified in the circuit variable
% C.INidx.  The first element in this array specifies to which neuron
% the first channel is injected, the second element to which neuron the second
% channel is injected etc (see example below).

% S{1}: channel 1 consists of input template 'I3' 
% and channel 2 of input template 'I4'

S{1} = generate(IT,1,{'I3' 'I4'},...
                       'amplify',[2e-3 2e-3],[0 0],...
                       'noisy offset',[13.5e-3 14e-3],[2e-4 1e-4],1e-2);

% S{2}: channel 2 consists of input template 'I4'
% and channel 3 of input templates 'I3' and 'I17'

S{2} = generate(IT,1,{'I3' 'I4' 'I17'},...
                       'amplify',[2e-3 2e-3 2e-3],[0 0 0],...
                       'noisy offset',[6e-3 14e-3 6e-3],[2e-4 2e-4 1e-4],1e-2); 

% There are three styles to plot the stimuli

STYLE = 1; % change this variable to 2 or 3 to see other styles
switch STYLE
    case 1
       % each stimlus (signal and parameter set) has an own figure
       figure(gcf+1)
       plot_instance(IT,S{1})
       figure(gcf+1)
       plot_instance(IT,S{2})
    case 2
       % all signals in one figure and all parameter sets in another figure
       figure(gcf+1)
       plot_instance(IT,S{:})
    case 3
       % all signals in one figure and every parameter set has an own figure
       figure(gcf+1)
       plot_instance(IT,S{:},'subplot',[111 111])
end

% generate circuits from the circuit templates
%---------------------------------------------

C = generate(CT{[1 14 20]});

% change into which neurons the three input channels are injected
% (channel 1 into neuron 3, channel 2 into neuron 1 ...)

C{3} = set(C{3},'INidx',[3 1 2]);

% Set that the response of all neurons in the circuit should be visualized

C{2} = set(C{2},'OUTidx',ALL);
C{3} = set(C{3},'OUTidx',ALL);


% plot the circuits

figure(gcf+1)
plot(C{:})


% visualize like sim1
%--------------------

figure(gcf+1)
visualize(C{:},S{:});


% visualize like sim2
%--------------------

figure(gcf+1)
visualize(C{:},S{:},'group','circuit');

