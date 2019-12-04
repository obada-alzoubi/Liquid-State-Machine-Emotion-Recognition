function this = train(this,TrainSet,varargin)


[TrainSet,ValidSet] = check_data(this,TrainSet,varargin);

t0=clock;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the projection in the low dimensional subspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% detect class labels and number of classes

this.model.class_label = unique(TrainSet.Y); % class values will also be sorted
nClasses = length(this.model.class_label);

% do within class calculations
% (Note: Scatter matrices can't be calculated without a loop)

for ncl = 1:nClasses
   idx = find(TrainSet.Y == this.model.class_label(ncl));
   nSamples(ncl) = length(idx);

   X = TrainSet.X(idx,:)';

   % calculate mass center of this class

   m(:,ncl) = mean(X,2);

   % calculate scatter matrix of this class

   S(:,:,ncl) = (X(:,:) - repmat(m(:,ncl),[1 nSamples(ncl)]))*...
                 (X(:,:) - repmat(m(:,ncl),[1 nSamples(ncl)]))';
end

% calculate total mass center

M = m*nSamples'/sum(nSamples);

% calculate within class scatter matrix

SW = sum(S,3);

% calculate between class scatter matrix

SB = repmat(nSamples,[size(m,1) 1]).*(m - repmat(M,[1 nClasses]))*...
      (m - repmat(M,[1 nClasses]))';

% calculate projection vectors

[V,D] = eig(pinv(SW)*SB); % Note: pinv doesn't care about zero rows/columns

[L,Li] = sort(diag(D));   % dont use dsort, otherwise toolbox user limitation
L = L(end:-1:1);
Li = Li(end:-1:1);


L = L(1:nClasses-1);
W = V(:,Li(1:nClasses-1));

% (automatic normalized)

% calculate error of pinv for largest EV

this.model.error = max(abs((SB - SW*L(1))*W(:,1)));

if (this.model.error > 1e-5)
   warn_str = sprintf('Within class scatter matrix is nearly singular. Error: %g',this.model.error);
   warning(warn_str)
end

% calculate criterion function

b = det(W' * SW * W);
if (b ~= 0)
   this.model.J = det(W' * SB * W)/b;
else
   this.model.J = Inf;
end

this.model.W = W;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the optimal threshold of the classification vectors.
% There's one vector for each class, pointing from the mass center
% of the class to the total mass center of the other classes (in
% the low dimensional projection space).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ncl = 1:nClasses

   % calculate total mass center of other classes

   other_cl = setdiff(1:nClasses,ncl);

   oM = m(:,other_cl)*nSamples(other_cl)'/sum(nSamples(other_cl));

   % calculate classification vector
   
   C(:,ncl) = W*W'*(m(:,ncl) - oM);
end

% normalize all classification vectors;

C = normc(C);

% brute force search for the optimal threshold for the classification vector

for ncl = 1:nClasses

   % split data into points of class ncl and points of other classes

   idx1 = find(TrainSet.Y == this.model.class_label(ncl));
   idx2 = setdiff(1:size(TrainSet.Y,1),idx1);

   T = ones(size(TrainSet.Y));
   T(idx2) = -1*ones(size(idx2));

   % calculate one dimensional projection of the two point sets

   Y = C(:,ncl)'*TrainSet.X';

   % sort point sets

   [Y,Tidx] = sort(Y);
   T = T(Tidx);

   fc = cumsum(T);
   [dummy,fc_min] = min(fc);

   % set biaz between points

   B(ncl) = mean( Y(max(fc_min-1,1):fc_min) );
end

this.model.B = B;
this.model.C = C;

this.time=etime(clock,t0);
