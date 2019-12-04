function []=plot_neuron_data(this,subpl)


   subplot(subpl) 
   cla
   hold on

   set(gca,'Color',[1 1 1])

   title('Pools')
   axis off

   xSt = 0;
   ySt = 0;
   dx = 10;
   dy = 5;

   neuron_fields = fieldnames(this.pool(1).parameters.Neuron(1));

   % plot all neuron names and indices

   NeuronTypeStr = {'I' 'P'};

   for j = 1:length(this.pool)
      if (this.pool(j).parameters.frac_EXC  == 0.0)
         typeIdx = 1;
      elseif (this.pool(j).parameters.frac_EXC  == 1.0)
         typeIdx = 2;
      else
         error('Plot function for mixed inh/exc pools not supported!')
      end

      text(xSt + (j+1)*dx,ySt,sprintf('%s_{%i}',NeuronTypeStr{typeIdx},j))
   end



   unit_str =  {'[F]','[Ohm]','[A]','[A]','[V]','[sec]','[V]','[V]','[V]'};


   for i = 1:length(neuron_fields)

      % check parameter range
      
      val = [];
      for j = 1:length(this.pool)
         typeIdx = this.pool(j).parameters.frac_EXC + 1;
         w = getfield(this.pool(j).parameters.Neuron(typeIdx),neuron_fields{i});
         if ~isempty(w)
            val(j,:) = w;
         end
      end
      
      j = find(any(val,2));
      maxVal = max(abs(val(:)));
      if ~isempty(j) & ~isempty(unit_str(i))
         if maxVal < 1e-9
            unit_str{i} = strrep(unit_str{i},'[','[p');
            val = val*1e12;
         elseif maxVal < 1e-6
            unit_str{i} = strrep(unit_str{i},'[','[n');
            val = val*1e9;
         elseif maxVal < 1e-3
            unit_str{i} = strrep(unit_str{i},'[','[u');
            val = val*1e6;
         elseif maxVal < 1
            unit_str{i} = strrep(unit_str{i},'[','[m');
            val = val*1e3;
         elseif maxVal < 1e3
            val = val;
         elseif maxVal < 1e6
            unit_str{i} = strrep(unit_str{i},'[','[k');
            val = val*1e-3;
         else
            unit_str{i} = strrep(unit_str{i},'[','[M');
            val = val*1e-6;
         end
      end

      % plot the field string
      fstr = strrep(char(neuron_fields(i)),'_',' ');

      text(xSt,ySt - i*dy,sprintf('%s %s',fstr,char(unit_str(i))));


      % plot neuron parameter row

      if ~isempty(val)
        for j = 1:length(this.pool)
	 textStr = sprintf('%0.3g - ',val(j,:));
         textStr(end-2:end) = [];
         text(xSt + (j+1)*dx,ySt - i*dy,textStr)
        end
      end
   end

   plot([0 dx*(length(this.pool)+2)],[-dy -dy]/2,'k-')

   plot([dx dx]*1.8,[-(length(neuron_fields)+0.5)*dy dy],'k-')

   axis([0 (length(this.pool)+2)*dx -(length(neuron_fields)+0.5)*dy dy])

