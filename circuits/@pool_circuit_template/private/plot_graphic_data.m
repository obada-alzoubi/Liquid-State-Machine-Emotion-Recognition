function []=plot_graphic_data(this,subpl)


   subplot(subpl)
   cla
   hold on

   set(gca,'Color',[1 1 1])

   nDist = 40;		% distance between pools
   sDistY = 4;		% distance between horizontal synapse lines
   sDistX = 6;		% distance between vertical synapse lines (at a neuron)
   sOffset = 20;	% distance between pool center and syn release site
   sHeight = 5;		% distance between syn release site and horiz line
   sInv = 2;		% length of diagonal line at syn release site
   LW = 0.02;		% line width factor
   LW = 1;		% line width factor


%   fs = min(10,10/(length(this.pool)/6));
   fs = 10;
   
   nFig = gcf;
   title(this.name,'FontSize',15)
   axis off

      % draw pools
      %-------------
      for nPool = 1:length(this.pool)
        if (this.pool(nPool).parameters.frac_EXC == 1)
      	    draw_pyramidal(nPool*nDist,0,nFig,...
   		sprintf('P_%i',nPool))
        elseif (this.pool(nPool).parameters.frac_EXC == 0)
            draw_interneuron(nPool*nDist,0,nFig,...
   		sprintf('I_%i',nPool))
	else
	   error('Plot function for mixed inh/exc pools not supported!')
        end
      end

      % draw input channels
      %--------------------

      for i = 1:length(this.input)
      	 text(this.INidx(i)*nDist,0,sprintf('%i',i),'Color',[1 1 1],...
            'HorizontalAlignment','center','FontSize',fs,'FontWeight','bold')
      end


      % classify synapse types
      %-----------------------

      forw_syn = [];
      back_syn = [];
      loop_syn = [];
      out_syn = [];
      forw_syn_type = [];
      back_syn_type = [];
      loop_syn_type = [];
      out_syn_type = [];

      for nConn = 1:length(this.conn)
         if ~isfield(this.conn(nConn),'add')
	    errstr = sprintf('Add command for connection %i missing',nConn);
	    error(errstr);
	 end
         if ((~isfield(this.conn(nConn).add,'src'))|(~isfield(this.conn(nConn).add,'dest')))
	    errstr = sprintf('Invalid src/dest index of add command of connection %i missing',nConn);
	    error(errstr);
	 end
	 
         switch this.conn(nConn).parameters.type
            case {'DynamicSpikingSynapse'}
               connType{nConn} = 'D';
            case {'StaticSpikingSynapse'}
               connType{nConn} = 'ST';
	    otherwise
               connType{nConn} = '?';
         end


         if (this.conn(nConn).add.dest > this.conn(nConn).add.src)
            % forward synapse

            forw_syn(end + 1,1) = nConn;
            forw_syn(end,2) = 1;
            forw_syn(end,3) = this.conn(nConn).add.src;
            forw_syn(end,4) = this.conn(nConn).add.dest;
            forw_syn(end,5) = 1;
            forw_syn_type{end+1} = connType{nConn};

         elseif (this.conn(nConn).add.src > this.conn(nConn).add.dest)
            % backward synapse

            back_syn(end + 1,1) = nConn;
            back_syn(end,2) = 2;
            back_syn(end,3) = this.conn(nConn).add.src;
            back_syn(end,4) = this.conn(nConn).add.dest;
            back_syn(end,5) = 1;
            back_syn_type{end+1} = connType{nConn};

         elseif (this.conn(nConn).add.src == this.conn(nConn).add.dest)
            % loop synapse

            loop_syn(end + 1,1) = nConn;
            loop_syn(end,2) = 3;
            loop_syn(end,3) = this.conn(nConn).add.src;
            loop_syn(end,4) = this.conn(nConn).add.dest;
            loop_syn(end,5) = 1;
            loop_syn_type{end+1} = connType{nConn};

         elseif isnan(this.conn(nConn).add.dest)
            % output synapse

            out_syn(end + 1,1) = nConn;
            out_syn(end,2) = 4;
            out_syn(end,3) = this.conn(nConn).add.src;
            out_syn(end,4) = this.conn(nConn).add.dest;
            out_syn(end,5) = 1;
            out_syn_type{end+1} = connType{nConn};
         end
      end

      % sort synapse types
      %-------------------

      if ~isempty(forw_syn)
        [d,di] = sort( forw_syn(:,3) );
        forw_syn = forw_syn(di,:);
        [d,di] = sort( forw_syn(:,4) - forw_syn(:,3) );
        d = d(end:-1:1);
        di = di(end:-1:1);
        forw_syn = forw_syn(di,:);
      end

      if ~isempty(back_syn)
        [d,di] = sort( back_syn(:,4) );
        back_syn = back_syn(di,:);
        [d,di] = sort( back_syn(:,3) - back_syn(:,4) );
        d = d(end:-1:1);
        di = di(end:-1:1);
        back_syn = back_syn(di,:);
      end

      % draw synapse types
      %-------------------

      for nSyn = 1:size(forw_syn,1)

         % find all endings at the same neuron
         i = find(forw_syn(:,3)==forw_syn(nSyn,3));
         j = find(forw_syn(:,4)==forw_syn(nSyn,3));
         rank = find(i==nSyn);

         % calculate x offset in dependence of the rank of the ending

         xo1 = (rank + length(j) - (length(i) + length(j) + 1)/2)*sDistX;

         i = find(forw_syn(:,4)==forw_syn(nSyn,4));
         j = find(forw_syn(:,3)==forw_syn(nSyn,4));
         rank = length(i)-find(i==nSyn)+1;
         xo2 = (rank - (length(i) + length(j) + 1)/2)*sDistX;

         x1 = xo1 + forw_syn(nSyn,3)*nDist;
         x2 = xo2 + forw_syn(nSyn,4)*nDist;
         y1 = sOffset;
         y2 = sOffset + sHeight + sDistY*(size(forw_syn,1)-nSyn+1);

         plot([x1 x2],[y2 y2],'k-','LineWidth',LW)
         plot([x1 x1],[y1 y2],'k-','LineWidth',LW)
         plot([x2 x2],[y1 y2],'k-','LineWidth',LW)
%         plot([x1 x2],[y2 y2],'k-','LineWidth',LW*forw_syn(nSyn,5))
%         plot([x1 x1],[y1 y2],'k-','LineWidth',LW*forw_syn(nSyn,5))
%         plot([x2 x2],[y1 y2],'k-','LineWidth',LW*forw_syn(nSyn,5))

         plot([x2-sInv x2],[y1-sInv y1],'k-','LineWidth',LW)
         plot([x2+sInv x2],[y1-sInv y1],'k-','LineWidth',LW)
%         plot([x2-sInv x2],[y1-sInv y1],'k-','LineWidth',LW*forw_syn(nSyn,5))
%         plot([x2+sInv x2],[y1-sInv y1],'k-','LineWidth',LW*forw_syn(nSyn,5))

         text(x2,y1-7,sprintf('%s_{%i}',...
   	forw_syn_type{nSyn},forw_syn(nSyn,1)),'HorizontalAlignment','center','FontSize',fs)
      end

      for nSyn = 1:size(back_syn,1)

         % find all endings at the same neuron
         i = find(back_syn(:,4)==back_syn(nSyn,4));
         j = find(back_syn(:,3)==back_syn(nSyn,4));
         rank = find(i==nSyn);

         % calculate x offset in dependence of the rank of the ending

         xo1 = (rank + length(j) - (length(i) + length(j) + 1)/2)*sDistX;

         i = find(back_syn(:,3)==back_syn(nSyn,3));
         j = find(back_syn(:,4)==back_syn(nSyn,3));
         rank = length(i)-find(i==nSyn)+1;
         xo2 = (rank - (length(i) + length(j) + 1)/2)*sDistX;

         x1 = xo1 + back_syn(nSyn,4)*nDist;
         x2 = xo2 + back_syn(nSyn,3)*nDist;
         y1 = sOffset;
         y2 = sOffset + sHeight + sDistY*(size(back_syn,1)-nSyn+1);

         plot([x1 x2],-[y2 y2],'k-','LineWidth',LW)
         plot([x1 x1],-[y1 y2],'k-','LineWidth',LW)
         plot([x2 x2],-[y1 y2],'k-','LineWidth',LW)
%         plot([x1 x2],-[y2 y2],'k-','LineWidth',LW*back_syn(nSyn,5))
%         plot([x1 x1],-[y1 y2],'k-','LineWidth',LW*back_syn(nSyn,5))
%         plot([x2 x2],-[y1 y2],'k-','LineWidth',LW*back_syn(nSyn,5))

         plot([x1-sInv x1],-[y1-sInv y1],'k-','LineWidth',LW)
         plot([x1+sInv x1],-[y1-sInv y1],'k-','LineWidth',LW)
%         plot([x1-sInv x1],-[y1-sInv y1],'k-','LineWidth',LW*back_syn(nSyn,5))
%         plot([x1+sInv x1],-[y1-sInv y1],'k-','LineWidth',LW*back_syn(nSyn,5))

         text(x1,-y1+4,sprintf('%s_{%i}',...
         	back_syn_type{nSyn},back_syn(nSyn,1)),'HorizontalAlignment','center','FontSize',fs)
      end

      for nSyn = 1:size(out_syn,1)

         x1 = out_syn(nSyn,3)*nDist + 8;
         x2 = (out_syn(nSyn,3) + 1/4)*nDist;
         y = 0;

         plot([x1 x2],[y y],'k-','LineWidth',LW)
%         plot([x1 x2],[y y],'k-','LineWidth',LW*out_syn(nSyn,5))

         plot([x2 x2+sInv],[y y+sInv],'k-','LineWidth',LW)
         plot([x2 x2+sInv],[y y-sInv],'k-','LineWidth',LW)
%         plot([x2 x2+sInv],[y y+sInv],'k-','LineWidth',LW*out_syn(nSyn,5))
%         plot([x2 x2+sInv],[y y-sInv],'k-','LineWidth',LW*out_syn(nSyn,5))

         text(x2,y-9,sprintf('%s_{%i}',...
         	out_syn_type{nSyn},out_syn(nSyn,1)),'HorizontalAlignment','center','FontSize',fs)
      end

      for nSyn = 1:size(loop_syn,1)

         X = loop_syn(nSyn,3)*nDist - 11;
         Y = 0;

         dRad = 2*pi/50;
         Rad = pi/4 : dRad :2*pi-pi/4;
         x = cos(Rad) * 3;
         y = sin(Rad) * 3;
         plot(X+x,Y+y,'k-','LineWidth',LW)
%         plot(X+x,Y+y,'k-','LineWidth',LW*loop_syn(nSyn,5))

         x = X + x(end);
         y = Y + y(end);

         plot([x x],[y y+sInv],'k-','LineWidth',LW)
         plot([x x+sInv],[y y],'k-','LineWidth',LW)
%         plot([x x],[y y+sInv],'k-','LineWidth',LW*loop_syn(nSyn,5))
%         plot([x x+sInv],[y y],'k-','LineWidth',LW*loop_syn(nSyn,5))
         text(X,Y-9,sprintf('%s_{%i}',...
         	loop_syn_type{nSyn},loop_syn(nSyn,1)),'HorizontalAlignment','center','FontSize',fs)
      end

      axis image
      v = axis;

      v(3) = min(v(3)*1.01,-sOffset*1.5);
      v(4) = max(v(4)*1.01,sOffset*1.5);
      axis(v)

