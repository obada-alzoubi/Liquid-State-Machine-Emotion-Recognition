function y=target_values(this,input,at_t)
 
nSegments  = length(input.info(1).actualTemplate);

L = input.info(1).Tstim/nSegments;
s = this.posSeg;

if this.multiClass
  v = (input.info(1).actualTemplate(s));
else
  v = (input.info(1).actualTemplate(s)==1);
end

if s > 1
  t = [0.0 (s-1)*L (s-1)*L+0.001  1e6  ];
  y = [v   v       v              v    ];
else
  t = [0.0  1e6];
  y = [v     v ];
end

y = interp1(t,y,at_t);

