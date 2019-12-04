function []=plot_synapse_data(this,subpl) 

   subplot(subpl)
   cla
   hold on

   set(gca,'Color',[1 1 1])

   title('Synapses')
   axis off

   xSt = 0;
   ySt = 0;
   dx = 10;
   dy = 5;

   synapse_fields = fieldnames(this.synapse);

   % font size

   fs = min(10,10/(length(this.synapse)/10));

   % plot all synapse names and indices

   for j = 1:length(this.synapse)
      text(xSt + (j+1)*dx,ySt,sprintf('%s_{%i}',this.synapse(j).type,j),'FontSize',fs)
   end

   % clear specification and type strings

   i = strmatch('type',synapse_fields,'exact');
   synapse_fields(i)=[];
   i = strmatch('spec',synapse_fields,'exact');
   synapse_fields(i)=[];
   i = strmatch('u_inf',synapse_fields,'exact');
   synapse_fields(i)=[];
   i = strmatch('r_inf',synapse_fields,'exact');
   synapse_fields(i)=[];

   unit_str =  {'','','','[sec]','[sec]','','','',''};


   for i = 1:length(synapse_fields)


      % check parameter range

      val = [];
      for j = 1:length(this.synapse)
         eval(sprintf('w = this.synapse(j).%s;',char(synapse_fields(i))));
         if ~isempty(w)
            val(j) = w;
         end
      end

      j = find(val);

      if ~isempty(j) & ~isempty(unit_str{i})
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
      fstr = strrep(char(synapse_fields(i)),'_',' ');
      
      text(xSt,ySt - i*dy,sprintf('%s %s',fstr,char(unit_str(i))),'FontSize',fs);

      % plot synapse parameter row
      if ~isempty(val)
        for j = 1:length(this.synapse)
            text(xSt + (j+1)*dx,ySt - i*dy,sprintf('%0.3g',val(j)),'FontSize',fs)
        end
      end
   end


   plot([0 dx*(length(this.synapse)+2)],[-dy -dy]/2,'k-')

   plot([dx dx]*1.8,[-(length(synapse_fields)+0.5)*dy dy],'k-')

   axis([0 (length(this.synapse)+2)*dx -(length(synapse_fields)+0.5)*dy dy]) 

