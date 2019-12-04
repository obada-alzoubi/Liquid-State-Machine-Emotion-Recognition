function O = apply(this,X)

if ~isempty(this.net)
  [O,Pf,Af,E,perf] = sim(this.net,X');
  O=O';
else
  warning('no model learned yet!');
end
