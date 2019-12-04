function response = simulate(this, Tsim, stimulus, TeacherSignal)

% SIMULATE Simulate the network
%
%  Syntax
%
%    response = simulate(nmc, Tsim, stimulus, TeacherSignal)
%
%  Arguments
%
%              nmc - neural microcircuit object
%             Tsim - simulation time
%         stimulus - stimulus for the input neurons
%    TeacherSignal - optional teacher signal (teacher forcing)
%
%         response - recorded response of the network
%
%  Description
%
%    SIMULATE simulates the network with the given stimulus (and optional teacher signal) for time Tsim
%    and returns the recorded response of the network.
%
%  See also Tutorial on circuit construction (www.lsm.tugraz.at)
%
%  Author
%
%    Christian Naeger, naeger@igi.tu-graz.ac.at

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
          %Added by Obada 
	if ( ci > length(stimulus(1).channel) )
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
for r=1:length(response)
  response{r}.Tsim = Tsim;
end
