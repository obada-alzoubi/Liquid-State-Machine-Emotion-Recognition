function []=plot_synapse_data(this,subpl)

   subplot(subpl)
   cla
   hold on

   set(gca,'Color',[1 1 1])

   title('Connections')
   axis off

   xSt = 0;
   ySt = 0;
   dx = 10;
   dy = 5;

   % synapse_fields = fieldnames(this.conn);
   synapse_fields = {'W' 'p' 'Inoise' 'U' 'D' 'F' 'delay' 'tau' 'f0'};

   % font size

   fs = min(10,10/(length(this.conn)/10));

   % plot all synapse names and indices

   connType = [];
   for j = 1:length(this.conn)
      switch this.conn(j).parameters.type
         case {'DynamicSpikingSynapse'}
            connType{j} = 'D';
         case {'StaticSpikingSynapse'}
            connType{j} = 'ST';
	 otherwise
            connType{j} = '?';
      end
      text(xSt + (j+1)*dx,ySt,sprintf('%s_{%i}',connType{j},j),'FontSize',fs)
   end

   % clear specification and type strings

   unit_str =  {'[A]','','[A]','','[sec]','[sec]','[sec]','[sec]','[Hz]'};


   for i = 1:length(synapse_fields)


      % check parameter range

      val = [];
      for j = 1:length(this.conn)

         PoolIdxDest = this.conn(j).add.dest;
         PoolIdxSrc = this.conn(j).add.src;
	 TypeIdxDest = this.pool(PoolIdxDest).parameters.frac_EXC + 1;
	 TypeIdxSrc = this.pool(PoolIdxSrc).parameters.frac_EXC + 1;

         typeIdx = (TypeIdxDest - 1)*2 + TypeIdxSrc;
	 if rem(typeIdx,1)
            error('Plot function for mixed inh/exc pools not supported!')
	 end

	 w = getfield(this.conn(j).parameters.Synapse(typeIdx),synapse_fields{i});
         if ~isempty(w)
            val(j,:) = w;
	    
	    switch synapse_fields{i}
	       case {'W'}
	          val(j,2) = val(j,1)*this.conn(j).parameters.SH_W;
	       case {'U','D','F'}
	          val(j,2) = val(j,1)*this.conn(j).parameters.SH_UDF;
	       case {'delay'}
	          val(j,2) = val(j,1)*this.conn(j).parameters.SH_delay;
	    end
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
      fstr = strrep(char(synapse_fields(i)),'_',' ');

      text(xSt,ySt - i*dy,sprintf('%s %s',fstr,char(unit_str(i))),'FontSize',fs);

      % plot synapse parameter row
      if ~isempty(val)
        for j = 1:length(this.conn)
  	   textStr = sprintf('%0.3g /pm ',val(j,:));

	   textStr(end-4:end) = [];
           text(xSt + (j+1)*dx,ySt - i*dy,strrep(textStr,'/pm','\pm'),'FontSize',fs)
        end
      end
   end


   plot([0 dx*(length(this.conn)+2)],[-dy -dy]/2,'k-')

   plot([dx dx]*1.8,[-(length(synapse_fields)+0.5)*dy dy],'k-')

   axis([0 (length(this.conn)+2)*dx -(length(synapse_fields)+0.5)*dy dy])

