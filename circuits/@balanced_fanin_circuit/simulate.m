function response = simulate(this, Tsim, stimulus, TeacherSignal)

if nargin <3, stimulus=[];      end
if nargin <4, TeacherSignal=[]; end

if isempty(stimulus)
  stimulus.channel = [];
else
  ci = 0; inputIdx = []; nInNeurons=0;
  for p=1:length(this.pool)  
    if this.pool(p).isInput
      inputIdx = [inputIdx double(this.pool(p).neuronIdx)];
      for i=1:length(this.pool(p).neuronIdx)
	if ( ci > length(stimulus.channel) )
	  error('Not enough inputs available!!');
	else
	  info=csim('get',this.pool(p).neuronIdx(i));
	  ci=ci+1;
	  if stimulus.channel(ci).spiking == info.spiking
	    stimulus.channel(ci).idx = this.pool(p).neuronIdx(i);
	  else
	    if stimulus.channel(ci).spiking, ch_str = 'spiking'; else ch_str = 'analog'; end
	    if info.spiking, n_str = 'spiking'; else n_str = 'analog'; end
	    error(sprintf('Input channel %i is %s while Input neuron %i is %s\n',...
		ci,ch_str,double(this.pool(p).neuronIdx(i)),n_str));
	  end	  
	end
      end
      nInNeurons = nInNeurons + length(this.pool(p).neuronIdx);
    end
  end

  if ( ci ~= nInNeurons ) 
    warning(sprintf('number of supplied input channels (%i) does not match number of input neurons (%i)',ci,nInNeurons)); 
  end

end

if isempty(TeacherSignal) 
  response = csim('simulate', Tsim, stimulus.channel);
else
  response = csim('simulate', Tsim, stimulus.channel, TeacherSignal.channel);
end
simTime = csim('get','t');
for r=1:length(response)
  response{r}.Tsim = simTime;
end
