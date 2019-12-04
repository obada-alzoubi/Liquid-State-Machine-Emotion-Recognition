function []=plot_neuron_data(this,subpl)


   subplot(subpl) 
   cla
   hold on

   set(gca,'Color',[1 1 1])

   title('Neurons')
   axis off

   xSt = 0;
   ySt = 0;
   dx = 10;
   dy = 5;

   neuron_fields = fieldnames(this.neuron);

   % plot all neuron names and indices

   for j = 1:length(this.neuron)
      text(xSt + (j+1)*dx,ySt,sprintf('%s_{%i}',this.neuron(j).type,j))
   end


   % clear specification and type strings

   i = strmatch('type',neuron_fields,'exact');
   neuron_fields(i)=[];
   i = strmatch('spec',neuron_fields,'exact');
   neuron_fields(i)=[];

   unit_str =  {'[V]','[V]','[V]','[V]','[sec]','[F]','[Ohm]','[A]','[A]'};


   for i = 1:length(neuron_fields)

      % check parameter range

      val = [];
      for j = 1:length(this.neuron)
         eval(sprintf('w = this.neuron(j).%s;',char(neuron_fields(i))));
         if ~isempty(w)
            val(j) = w;
         end
      end

      j = find(val);
      if ~isempty(j) & ~isempty(unit_str(i))
         if max(abs(val)) < 1e-9
            unit_str{i} = strrep(unit_str{i},'[','[p');
            val = val*1e12;
         elseif max(abs(val)) < 1e-6
            unit_str{i} = strrep(unit_str{i},'[','[n');
            val = val*1e9;
         elseif max(abs(val)) < 1e-3
            unit_str{i} = strrep(unit_str{i},'[','[u');
            val = val*1e6;
         elseif max(abs(val)) < 1
            unit_str{i} = strrep(unit_str{i},'[','[m');
            val = val*1e3;
         end
      end

      % plot the field string
      fstr = strrep(char(neuron_fields(i)),'_',' ');
      
      text(xSt,ySt - i*dy,sprintf('%s %s',fstr,char(unit_str(i))));


      % plot neuron parameter row

      if ~isempty(val)
        for j = 1:length(this.neuron)
         text(xSt + (j+1)*dx,ySt - i*dy,sprintf('%0.3g',val(j)))
        end
      end
   end

   plot([0 dx*(length(this.neuron)+2)],[-dy -dy]/2,'k-')

   plot([dx dx]*1.8,[-(length(neuron_fields)+0.5)*dy dy],'k-')

   axis([0 (length(this.neuron)+2)*dx -(length(neuron_fields)+0.5)*dy dy]) 

