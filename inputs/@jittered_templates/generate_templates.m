function this=generate_templates(this)

tau_refract=3e-3;

nSegments = length(this.nTemplates);
for s=1:nSegments
  for i=1:this.nTemplates(s)
    for j=1:this.nChannels
      if ~isempty(this.nSpikes)
	st = [];
	while isempty(st)
	  st = cumsum(tau_refract+exponentialrnd(1/this.freq(s)-tau_refract,1,this.nSpikes(s)));
          st = st(st<this.Tstim/nSegments); % change by Stefan
%	  st = st/max(st)*(this.Tstim/nSegments*(0.8+0.2*rand)); % change by Stefan
	end
      elseif ~isempty(this.freq)
	st = [];
	% while isempty(st)   % change by Stefan
	  st = cumsum(tau_refract+exponentialrnd(1/this.freq(s)-tau_refract,1,ceil(5*this.freq(s)*this.Tstim)));
	  st = st(st<=this.Tstim/nSegments);
	% end
      end
      st = st+(s-1)*this.Tstim/nSegments;
      this.segment(s).template(i).st{j} = st;
    end
  end
end
