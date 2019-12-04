function [neur_idx,neur_pos] = vol2neur(nmc, volume)

  
% find all neurons in the given volume

neur_idx = [];
neur_pos = [];

for i = 1:length(nmc.pool)

  p = nmc.pool(i).pos;
  s = nmc.pool(i).size;
  
  %
  % calculate position of all neurons in pool i
  %
  [x y z] = ind2sub(s, 1:prod(s));
  x=x+p(1)-1;
  y=y+p(2)-1;
  z=z+p(3)-1;
  POS = [x; y; z];
  clear x y z
  
  %
  % find the overlap of pool i with destination volume
  %
  ni = all( POS  >= repmat(volume(1, :)', 1, prod(s)) & ...
      POS  <= repmat(volume(2, :)', 1, prod(s)) );
  
  neur_pos = [neur_pos POS(:,ni)];
  
  neur_idx = [neur_idx nmc.pool(i).neuronIdx(find(ni))];

end    
  
