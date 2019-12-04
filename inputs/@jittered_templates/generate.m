function stimulus=generate(this,varargin)

nSegments = length(this.nTemplates);

switch this.templ_selection
   case 'random'
      ti = ceil(rand(1,nSegments).*this.nTemplates);
   case 'sequential'
      digit_base = [1 cumprod(this.nTemplates(1:end-1))];
      if nargin < 3
         i = floor(rand*prod(this.nTemplates));
      else
         i = max(varargin{2}-1,0);
      end
      ti = mod(floor(i./digit_base),this.nTemplates)+1;
   otherwise
      err_str = sprintf('Template selection ''%s'' unknown!',this.templ_selection);
      error(err_str)
end



for j=1:this.nChannels
  st = [];
  for s=1:nSegments
    st =  [st this.segment(s).template(ti(s)).st{j}];
  end
  if (this.jitter > 0) & ~isempty(st)
    st = st + gaussrnd(0,this.jitter,1,length(st));
    st = st(st >=0 & st<this.Tstim);
    st = sort(st);
  end
  stimulus.channel(j).data    = st;
  stimulus.channel(j).spiking = 1;
  stimulus.channel(j).dt      = -1;
end

stimulus.info(1).Tstim          = this.Tstim;
stimulus.info(1).actualTemplate = ti;
