function default = all_default_parameters();

additional_definitions

default.NOISE    = 0.0;


default.Ascale   = 2.5;          % scaling of the A-parameter (weights of synapses)

default.neur(EXZ).Ibase    = [0 0];               % interval from which Ib is drawn randomly
default.neur(INH).Ibase    = [0 0];               % interval from which Ib is drawn randomly
default.neur(EXZ).thresh   = 15e-3;                  % threshold of the neurons
default.neur(INH).thresh   = 15e-3; 
default.neur(EXZ).abs_refr = 0.003;               % absolute refractory period
default.neur(INH).abs_refr = 0.002;
default.neur(EXZ).tau_m    = 0.03;                % membrane time-constant
default.neur(INH).tau_m    = 0.03;
default.neur(EXZ).vm_reset = 13.5e-3;                % membrane voltage after spike
default.neur(INH).vm_reset = 13.5e-3;
default.neur(EXZ).inject   = 15.1e-3;                % injected current (overruled by Ibase!)
default.neur(INH).inject   = 15.1e-3;
default.neur(EXZ).vm_init  = 13.5e-3;                % membrane voltage at start of sim
default.neur(INH).vm_init  = 13.5e-3;
				
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% default SYNAPTIC CONNECTION PARAMETERS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

default.conn(EE).C     = 0.3;    % EXZ to EXZ synapse  
default.conn(IE).C     = 0.2;    % EXZ to INH synapses 
default.conn(EI).C     = 0.4;    % INH to EXZ synapses 
default.conn(II).C     = 0.1;    % INH to INH synapses 

default.conn(STATIC).A     = 30e-3;     % [mV] mean weight of synapse  
default.conn(STATIC).delay = 1.5e-3; % mean of axonal delay (CV is 0.1) 
default.conn(STATIC).tau   = 3e-3;   % PSP time-constant (CV is 0.0) 

                       		 % EXZ to EXZ synapses 
default.conn(EE).A     = 90e-3;     % [mV] mean weight of synapse  
default.conn(EE).noise = 0.0;    % noise added to PSC 
default.conn(EE).U     = 0.5;    % mean dyn. U-parameter 
default.conn(EE).D     = 1.1;    % mean dyn. D-parameter 
default.conn(EE).F     = 0.05;   % mean dyn. F-Parameter 
default.conn(EE).delay = 1.5e-3; % mean of axonal delay (CV is 0.1) 
default.conn(EE).tau   = 3e-3;   % PSP time-constant (CV is 0.0) 
default.conn(EE).f0    = 6;      % frequency used to calculate initial values for r and u of  
                                 % dynamic synapses: r(0) = r_inf and u(0) = u_inf 
 	                         % see PNAS paper for equations 
    
default.conn(IEf).A     = 60e-3;   
default.conn(IEf).noise = 0.0;  
default.conn(IEf).U     = 0.05; 
default.conn(IEf).D     = 0.125; 
default.conn(IEf).F     = 1.2; 
default.conn(IEf).delay = 0.7e-3; 
default.conn(IEf).tau   = 3e-3; 
default.conn(IEf).f0    = 6; 
 
default.conn(IEd).A     = 60e-3;   
default.conn(IEd).noise = 0.0;   
default.conn(IEd).U     = 0.72; 
default.conn(IEd).D     = 0.227; 
default.conn(IEd).F     = 0.013; 
default.conn(IEd).delay = 0.7e-3; 
default.conn(IEd).tau   = 3e-3; 
default.conn(IEd).f0    = 6; 
 
default.conn(F1).A     = -19e-3;
default.conn(F1).noise = 0.0;  
default.conn(F1).U     = 0.16; 
default.conn(F1).D     = 0.045; 
default.conn(F1).F     = 0.376; 
default.conn(F1).delay = 0.8e-3; 
default.conn(F1).tau   = 6e-3; 
default.conn(F1).f0    = 6; 
 
default.conn(F2).A     = -19e-3;   
default.conn(F2).noise = 0.0;   
default.conn(F2).U     = 0.25; 
default.conn(F2).D     = 0.706; 
default.conn(F2).F     = 0.021; 
default.conn(F2).delay = 0.8e-3; 
default.conn(F2).tau   = 6e-3; 
default.conn(F2).f0    = 6; 
 
default.conn(F3).A     = -19e-3;  
default.conn(F3).noise = 0.0;    
default.conn(F3).U     = 0.32; 
default.conn(F3).D     = 0.144; 
default.conn(F3).F     = 0.062; 
default.conn(F3).delay = 0.8e-3; 
default.conn(F3).tau   = 6e-3; 
default.conn(F3).f0    = 6; 
 


