function response = simulate(this, Tsim, S, TeacherSignal)

if nargin <3, S=[];      end
if nargin <4, TeacherSignal=[]; end

if isempty(S)
  S.channel = [];
end

if length(S.channel) == 0
  response{1} = [];
end

if length(S.channel) ~= this.nInputs
  error('number of input channels not equal number of inputs specified for fake liquid!');
end

j=0;
response{1}.channel(this.nMulti*this.nInputs).data = [];
for m=1:this.nMulti
  for i=1:length(S.channel)
    st=S.channel(i).data;
    j=j+1;
    st=st+this.delays(j);
    if ( this.jitter > 0 )
      st=st+gaussrnd(0,this.jitter,1,length(st));
    end
    response{1}.channel(j).data = st;  
  end
end

[response{1}.channel.spiking]=deal(1);
[response{1}.channel.dt]=deal(-1);
response{1}.Tsim=Tsim;

