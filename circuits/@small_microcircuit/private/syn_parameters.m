function conn = syn_parameters;

additional_definitions;

conn(EE).U     = 0.5;    % mean dyn. U-parameter 
conn(EE).D     = 1.1;    % mean dyn. D-parameter 
conn(EE).F     = 0.05;   % mean dyn. F-Parameter 

conn(IEf).U     = 0.05; 
conn(IEf).D     = 0.125; 
conn(IEf).F     = 1.2; 

conn(IEd).U     = 0.72; 
conn(IEd).D     = 0.227; 
conn(IEd).F     = 0.013; 

conn(F1).U     = 0.16; 
conn(F1).D     = 0.045; 
conn(F1).F     = 0.376; 

conn(F2).U     = 0.25; 
conn(F2).D     = 0.706; 
conn(F2).F     = 0.021; 

conn(F3).U     = 0.32; 
conn(F3).D     = 0.144; 
conn(F3).F     = 0.062; 

