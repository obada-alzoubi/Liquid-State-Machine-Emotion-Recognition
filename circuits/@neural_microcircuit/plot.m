function plot(nmc, varargin)

% PLOT opens an interactive 3D visualization of the network
%
%  Syntax
%
%    plot(nmc)
%
%  Arguments
%
%              nmc - neural microcircuit object
%
%  See also Tutorial on circuit construction (www.lsm.tugraz.at)
%
%  Author
%
%    Christian Naeger, naeger@igi.tu-graz.ac.at

global_definitions;


% eval(sprintf('global %s_figureHandles;', inputname(1)))

if isempty(nmc.pool)
  fprintf('There are no pools of neurons. Command ignored.\n');
  return
end


fh.fig = gcf; clf; hold on;


set(fh.fig, 'Name', 'Neural Microcircuit');


colormap cool;
camproj('perspective');
sp = min(vertcat(nmc.pool(:).pos), [], 1);
lp = max(vertcat(nmc.pool(:).pos) + vertcat(nmc.pool(:).size) -1, [], 1);
cp = sp+(lp-sp)/2;
campos([-cp(1)*8 -cp(2)*20 cp(3)*2]);
camlight headlight;



fh.neurCM.labels = { ...
    'Incoming', ... 
    'Outgoing', ...
    'EXC feedback loops (1. order)', ...
    'EXC feedback loops (2. order)', ...
    'EXC feedback loops (3. order)',  ...
    };

fh.neurCM.tags = { ...
    'in', ... 
    'out', ...
    'efb1', ...
    'efb2', ...
    'efb3' ...
    };

    
fh.neurCM.defaults = [1 1 0 0 0];

%if length(varargin) > 0
%  fh.clickdef = varargin{1};
%else
%  fh.clickdef = {'Incoming', 'Outgoing'};
%end

% Context Menu for the Neurons

fh.neurCM.cm = uicontextmenu('Parent', fh.fig, 'Callback', @neurcm_callback);
for s = 1:length(fh.neurCM.labels)
  fh.neurCM.mi(s) = uimenu(...
      'Parent', fh.neurCM.cm, ...
      'Label',  fh.neurCM.labels{s}, ...
      'Tag',    fh.neurCM.tags{s}, ...
      'Callback', {@neurcm_callback_click, nmc});
end



% Context Menu for the figure

fh.figCM.cm = uicontextmenu('Parent', fh.fig);
fh.figCM.pool = uimenu('Parent', fh.figCM.cm, 'Label', 'Pool');
for s = 1:length(nmc.pool)
  fh.figCM.poolmi(s) = uimenu(...
      'Parent', fh.figCM.pool, ...
      'Label', sprintf('Pool %i', s), ...
      'Tag', num2str(s), ...
      'Callback', {@pool_callback, nmc});
end
fh.figCM.clickdef = uimenu('Parent', fh.figCM.cm, 'Label', 'Click defaults');
for s = 1:length(fh.neurCM.labels)
  fh.figCM.clickdefmi(s) = uimenu(...
      'Parent', fh.figCM.clickdef, ...
      'Label',  fh.neurCM.labels{s}, ...
      'Tag',    fh.neurCM.tags{s}, ...
      'Callback', @clickdef_callback);
  if fh.neurCM.defaults(s) == 0
    set(fh.figCM.clickdefmi(s), 'Checked', 'off');
  else
    set(fh.figCM.clickdefmi(s), 'Checked', 'on');
  end
end
fh.figCM.clearall = uimenu(...
      'Parent', fh.figCM.cm, ...
      'Label', 'Clear all connections', ...
      'Callback', {@clear_callback, nmc});
set(fh.fig, 'UIContextMenu', fh.figCM.cm);




% plot the pools

for p = 1:length(nmc.pool)

  Nx = nmc.pool(p).size(1);
  Ny = nmc.pool(p).size(2);
  Nz = nmc.pool(p).size(3);

  X = repmat([1:Nx]',[1 Ny Nz]);
  X = X(:)';
  Y = repmat([1:Ny],[Nx 1 Nz]);
  Y = Y(:)';
  Z = zeros(1,1,Nz);
  Z(1,1,1:Nz) = 1:Nz;
  Z = repmat(Z,[Nx Ny 1]);
  Z = Z(:)';
  
  [xs,ys,zs] = sphere(10);
  ss=0.1;
  xs=xs*ss;
  ys=ys*ss;
  zs=zs*ss;
  cs=zs;
  
  xs = xs + nmc.pool(p).pos(1) - 1;
  ys = ys + nmc.pool(p).pos(2) - 1;
  zs = zs + nmc.pool(p).pos(3) - 1;
  
  planeX = nmc.pool(p).pos(1) : nmc.pool(p).pos(1)+nmc.pool(p).size(1) - 1;
  planeY = nmc.pool(p).pos(2) : nmc.pool(p).pos(2)+nmc.pool(p).size(2) - 1;
  
  type = csim('get', nmc.pool(p).neuronIdx, 'type');
  
  for z=1:Nz
    if (Nx > 1 & Ny > 1)
      fh.pool(p).plane(z) = surf(planeX, planeY, zeros(Ny, Nx)+nmc.pool(p).pos(3)+z-1, ...
	  'EdgeColor', 'none', 'FaceAlpha', 0.15, 'HitTest', 'off');
    end
    for x=1:Nx
      for y=1:Ny
	ni = sub2ind(nmc.pool(p).size, x, y, z);
	idx = nmc.pool(p).neuronIdx(ni);
	t = (type(ni) == INH);
	fh.pool(p).neuron(ni).neuronH = surf(x+xs,y+ys,z+zs, ones(size(zs)) + 16 + t*32, ...
	    'EdgeColor', 'none', 'CDataMapping', 'direct', ...
	    'UserData', [idx, p, ni], ...
	    'UIContextMenu', fh.neurCM.cm, 'ButtonDownFcn', {@neuron_callback, nmc, p, ni});
	for s = 1:length(fh.neurCM.defaults)
	  eval(sprintf('fh.pool(p).neuron(ni).%s = NaN;', fh.neurCM.tags{s}));
	end
      end
    end
  end
  
end

set(gca, 'XTick', sp(1):lp(1), 'YTick', sp(2):lp(2), 'ZTick', sp(3):lp(3), ...
    'XLim', [sp(1)-2*ss lp(1)+2*ss], 'Ylim', [sp(2)-2*ss lp(2)+2*ss], 'ZLim', [sp(3)-2*ss lp(3)+2*ss], ...
    'DataAspectRatio', [1 1 1]);
grid
xlabel('x');
ylabel('y');
zlabel('z');



guidata(fh.fig, fh); 

% eval(sprintf('%s_figureHandles = fh;', inputname(1)))







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Callbacks
%


function neuron_callback(h, eventdata, nmc, p, ni)

fh = guidata(gcbo);

if isempty(h) | strcmp(get(fh.fig, 'SelectionType'), 'normal')

  fprintf('Neuron idx: %d\n', double(nmc.pool(p).neuronIdx(ni)));
  
  del = 1; s = 1;
  while s <= length(fh.neurCM.defaults) & del == 1
    if fh.neurCM.defaults(s) == 1 & isnan(eval(sprintf('fh.pool(p).neuron(ni).%s', fh.neurCM.tags{s})))
      del = 0;
    end
    s = s+1;
  end

  if del == 0
    fh = nmcgui_create(fh, nmc, p, ni);
  else
    fh = nmcgui_delete(fh, nmc, p, ni);
  end

  guidata(gcbo, fh);
end




function pool_callback(h, eventdata, nmc)

p = str2double(get(h, 'tag'));
for ni = 1:length(nmc.pool(p).neuronIdx);
  neuron_callback([], [], nmc, p, ni)
end



function clear_callback(h, eventdata, nmc)
fh = guidata(gcbo);

for p = 1:length(nmc.pool)
  for ni = 1:length(nmc.pool(p).neuronIdx);
    for s = 1:length(fh.neurCM.defaults)
      current = eval(sprintf('fh.pool(p).neuron(ni).%s', fh.neurCM.tags{s}));
    
      if ~isnan(current)
	delete(current)
      end
    
      eval(sprintf('fh.pool(p).neuron(ni).%s = NaN;', fh.neurCM.tags{s}));
    end
  end
end

guidata(gcbo, fh);




function clickdef_callback(h, eventdata)

fh = guidata(gcbo);

tag = get(h, 'Tag');

a = strmatch(tag, fh.neurCM.tags(:), 'exact');
if ~isempty(a)
  
  if strcmp(get(h, 'Checked'), 'off');
    fh.neurCM.defaults(a) = 1;
    set(h, 'Checked', 'on');
  else
    fh.neurCM.defaults(a) = 0;
    set(h, 'Checked', 'off');
  end
  
  guidata(gcbo, fh);

end




function neurcm_callback(h, eventdata)

fh = guidata(gcbo);
nh = get(fh.fig, 'CurrentObject');

[idx, p, ni] = nmcgui_getNeuronData(nh);

for s = 1:length(fh.neurCM.tags)
  if isnan(eval(sprintf('fh.pool(p).neuron(ni).%s', fh.neurCM.tags{s})))
    set(fh.neurCM.mi(s), 'Checked', 'off');
  else
    set(fh.neurCM.mi(s), 'Checked', 'on');
  end
end




function neurcm_callback_click(h, eventdata, nmc)

fh = guidata(gcbo);
nh = get(fh.fig, 'CurrentObject');
[idx, p, ni] = nmcgui_getNeuronData(nh);

if strcmp(get(h, 'Checked'), 'off')

  fh = feval(sprintf('nmcgui_create_%s', get(h, 'Tag')), fh, nmc, p, ni);
  
else
  
  current = eval(sprintf('fh.pool(p).neuron(ni).%s', get(h, 'Tag')));
  
  if ~isnan(current)
    delete(current)
  end
  
  eval(sprintf('fh.pool(p).neuron(ni).%s = NaN;', get(h, 'Tag')));
  
  set(h, 'Checked', 'off');

end

guidata(gcbo, fh);






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Helper functions
%


function [idx, p, ni] = nmcgui_getNeuronData(h)

data = get(h, 'UserData');

idx = uint32(data(1));
p = double(data(2));
ni = double(data(3));




function fh = nmcgui_create(fh, nmc, p, ni)

for s = 1:length(fh.neurCM.defaults)

  if fh.neurCM.defaults(s) == 1
    current = eval(sprintf('fh.pool(p).neuron(ni).%s', fh.neurCM.tags{s}));

    if isnan(current)
      fh = feval(sprintf('nmcgui_create_%s', fh.neurCM.tags{s}), fh, nmc, p, ni);
    end

  end

end



function fh = nmcgui_delete(fh, nmc, p, ni)

for s = 1:length(fh.neurCM.defaults)

  if fh.neurCM.defaults(s) == 1
    current = eval(sprintf('fh.pool(p).neuron(ni).%s', fh.neurCM.tags{s}));

    if ~isnan(current)
      delete(current)
    end

    eval(sprintf('fh.pool(p).neuron(ni).%s = NaN;', fh.neurCM.tags{s}));
  end

end





function fh = nmcgui_create_in(fh, nmc, p, ni)

global_definitions;

% fprintf('Incoming:\n');

cmap = get(fh.fig, 'Colormap');

idx = nmc.pool(p).neuronIdx(ni);

[pre, post] = csim('get', idx, 'connections');
type = (double(csim('get', idx, 'type')) == INH);

fh.pool(p).neuron(ni).in = [];

for i = 1:length(pre)
  [n1, n2] = csim('get', pre(i), 'connections');
  % search n1
  for j = 1:length(nmc.pool)
    a = find(nmc.pool(j).neuronIdx == double(n1));
    if (~isempty(a)), break, end;
  end
  if (isempty(a))
    fprintf('WARNING: Could not find neuron %i which is connected to neuron %i via synapse %i.\n', ...
	double(n1), double(idx), double(pre(i)));
  else
    % fprintf('Neuron %i -> Synapse %i -> Neuron %i\n', double(n1), double(pre(i)), double(idx));
    type = (double(csim('get', n1, 'type')) == INH);
    [x1 y1 z1] = ind2sub(nmc.pool(p).size, ni);
    [x2 y2 z2] = ind2sub(nmc.pool(j).size, a);
    l = [nmc.pool(p).pos + [x1 y1 z1] - 1 ; nmc.pool(j).pos + [x2 y2 z2] - 1];
    fh.pool(p).neuron(ni).in(i) = plot3(l(:,1), l(:,2), l(:,3), 'Color', cmap(16+type*32, :), 'HitTest', 'off');
  end
end




function fh = nmcgui_create_out(fh, nmc, p, ni)

global_definitions;

% fprintf('\nOutgoing:\n');

cmap = get(fh.fig, 'Colormap');

idx = nmc.pool(p).neuronIdx(ni);

[pre, post] = csim('get', idx, 'connections');
type = (double(csim('get', idx, 'type')) == INH);

fh.pool(p).neuron(ni).out = [];

for i = 1:length(post)
  [n1, n2] = csim('get', post(i), 'connections');
  % search n2
  for j = 1:length(nmc.pool)
    a = find(nmc.pool(j).neuronIdx == double(n2));
    if (~isempty(a)), break, end;
  end
  if (isempty(a))
    fprintf('WARNING: Could not find neuron %i which is connected to neuron %i via synapse %i.\n', ...
	double(n2), double(idx), double(post(i)));
  else
    % fprintf('Neuron %i -> Synapse %i -> Neuron %i\n', double(idx), double(post(i)), double(n2));
    [x1 y1 z1] = ind2sub(nmc.pool(p).size, ni);
    [x2 y2 z2] = ind2sub(nmc.pool(j).size, a);
    l = [nmc.pool(p).pos + [x1 y1 z1] - 1 ; nmc.pool(j).pos + [x2 y2 z2] - 1];
    fh.pool(p).neuron(ni).out(i) = plot3(l(:,1), l(:,2), l(:,3), 'Color', cmap(16+type*32, :), 'HitTest', 'off');
  end
end




function fh = nmcgui_create_efb1(fh, nmc, p, ni)

global_definitions;

idx = nmc.pool(p).neuronIdx(ni);
if double(csim('get', idx, 'type')) == EXC

  efb = bfs(nmc, idx, idx, 2, EXC);
  efb = efb(:);

  fh.pool(p).neuron(ni).efb1 = [];
  if ~isempty(efb)
    fh.pool(p).neuron(ni).efb1 = nmcgui_plot_syn(nmc, efb, get(fh.fig, 'Colormap'));
  end
end

function fh = nmcgui_create_efb2(fh, nmc, p, ni)

global_definitions;

idx = nmc.pool(p).neuronIdx(ni);
if double(csim('get', idx, 'type')) == EXC

  efb = bfs(nmc, idx, idx, 3, EXC);
  efb = efb(:);

  fh.pool(p).neuron(ni).efb2 = [];
  if ~isempty(efb)
    fh.pool(p).neuron(ni).efb2 = nmcgui_plot_syn(nmc, efb, get(fh.fig, 'Colormap'));
  end
end

function fh = nmcgui_create_efb3(fh, nmc, p, ni)

global_definitions;

idx = nmc.pool(p).neuronIdx(ni);
if double(csim('get', idx, 'type')) == EXC

  efb = bfs(nmc, idx, idx, 4, EXC);
  efb = efb(:);

  fh.pool(p).neuron(ni).efb3 = [];
  if ~isempty(efb)
    fh.pool(p).neuron(ni).efb3 = nmcgui_plot_syn(nmc, efb, get(fh.fig, 'Colormap'));
  end
end




function sh = nmcgui_plot_syn(nmc, sidx, cmap)

for i = 1:length(sidx)

  [n1, n2] = csim('get', sidx(i), 'connections');

  % search n1
  for j = 1:length(nmc.pool)
    a = find(nmc.pool(j).neuronIdx == double(n1));
    if ~isempty(a), break, end;
  end

  % search n2
  for k = 1:length(nmc.pool)
    b = find(nmc.pool(j).neuronIdx == double(n2));
    if ~isempty(b), break, end;
  end

  if isempty(a)
    fprintf('WARNING: Could not find neuron %i in connection: Neuron %i -> Synapse %i -> Neuron %i.\n', ...
	double(n1), double(n1), double(sidx(i)), double(n2));
  elseif isempty(b)
    fprintf('WARNING: Could not find neuron %i in connection: Neuron %i -> Synapse %i -> Neuron %i.\n', ...
	double(n2), double(n1), double(sidx(i)), double(n2));
  else
    % fprintf('Neuron %i -> Synapse %i -> Neuron %i\n', double(n1), double(sidx(i)), double(n2));
    [x1 y1 z1] = ind2sub(nmc.pool(j).size, a);
    [x2 y2 z2] = ind2sub(nmc.pool(k).size, b);
    l = [nmc.pool(j).pos + [x1 y1 z1] - 1; nmc.pool(k).pos + [x2 y2 z2] - 1];
    sh(i) = plot3(l(:,1), l(:,2), l(:,3), 'Color', cmap(16, :), 'HitTest', 'off', 'LineWidth', 2);
  end
end

