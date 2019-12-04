function synIdx = bfs(nmc, neurIdx_start, neurIdx_goal, depth, neur_type)

% BFS breadth-first-search
%
%  Syntax
%
%    synidx = bfs(nmc, neurIdx_start, neurIdx_goal, depth, neur_type)
%
%  Arguments
%
%              nmc - neural microcircuit object
%    neurIdx_start - start neuron (csim index)
%    neurIdx_goal  - goal neuron (csim index)
%            depth - search depth
%        neur_type - type of the neurons
%
%    neurIdx_start - list of synapses (csim indices)
%
%  Description
%
%    Breadth-first search from start to goal with fixed depth
%    (i.e. find all paths from start to goal with exactly depth steps).
%    The neurons between start and goal are of type neur_type only.
%    [EXPERIMENTAL: currently not used]
%
%
%  Author
%
%    Christian Naeger, naeger@igi.tu-graz.ac.at


global_definitions;

if ~ismember(csim('get', neurIdx_start, 'type'), neur_type)
  synIdx = [];
  return;
end

[preS,  postS] = csim('get', neurIdx_start, 'connections');

S = postS;
D = ones(1, length(postS));
B = -1 * ones(1, length(postS));

c = 1;


% build bf search "tree" till given depth

while c <= length(S) & D(c) < depth

  [preN, postN] = csim('get', S(c), 'connections');

  if ismember(csim('get', postN, 'type'), neur_type)
    [preS, postS] = csim('get', postN, 'connections');

    S = [S, postS];
    D = [D, D(c)+1 * ones(1, length(postS))];
    B = [B, c * ones(1, length(postS))];
  end

  c = c + 1;
end



synIdx = [];

if c > length(S)
  if VERBOSE_LEVEL > 0
    fprintf('Warning: Could not reach search depth.\n');
  end
else

  % search for goal in the given depth

  ii = find(D == depth);
  for c = 1:length(ii)
    [preN, postN] = csim('get', S(ii(c)), 'connections');

    if postN == neurIdx_goal
      % goal found => back-tracking
      temp = ii(c);
      path = S(temp);

      for d = depth-1:-1:1
	temp = B(temp);
	path = [path, S(temp)];
      end
      synIdx = [synIdx; path(end:-1:1)];

    end

  end

end

