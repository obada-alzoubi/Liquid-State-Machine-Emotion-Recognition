function preprocess(this)
%
% input: flatX flatY
% putput: TrainSet ValidSet TestSet
%

% options = flatten_data(targets,options);

if ~isfield(options,'split_frac')
  options.split_frac = [ 0.7 0.15 0.15 ];
end
sfrac = options.split_frac / sum(options.split_frac);
sidx  = [ 0 ceil(cumsum(sfrac*size(flatX,1))) ];

TrainSet.idx=sidx(1)+1:sidx(2);
TrainSet.X = flatX(TrainSet.idx,:);
TrainSet.Y = flatY(TrainSet.idx,:);

ValidSet.idx=sidx(2)+1:sidx(3);
ValidSet.X = flatX(ValidSet.idx,:);
ValidSet.Y = flatY(ValidSet.idx,:);

TestSet.idx=sidx(3)+1:sidx(4);
TestSet.X  = flatX(TestSet.idx,:);
TestSet.Y  = flatY(TestSet.idx,:);

if ~isfield(options,'DOPCA'), options.DOPCA = 0; end
if ~isfield(options,'var_frac'), options.var_frac = -1; end
if ~isfield(options,'DOSTDNORM'), options.DOSTDNORM = 0; end
if ~isfield(options,'NOISE'), options.NOISE = 0; end
if ~isfield(options,'NOISY_DUPLICATES'), options.NOISY_DUPLICATES = 0; end
if ~isfield(options,'y_range'), options.y_range = [-1 1]; end

options.PCA_Matrix = [];
if options.DOPCA
  d=size(TrainSet.X,2);
  verbose(0,'applying pca transformation ...');
  [TrainSet.X,options.PCA_Matrix]=calc_pca(TrainSet.X,options.var_frac);
  ValidSet.X = apply_pca(ValidSet.X,options.PCA_Matrix);
  TestSet.X  = apply_pca(TestSet.X,options.PCA_Matrix);
  verbose(0,'\b\b\b\b. Keeping %i of %i dimensions.\n',size(TrainSet.X,2),d);
end


options.meanx = [];
options.stdx  = [];
if options.DOSTDNORM
   verbose(0,'applying mean/std transformation ...');
   [TrainSet.X,options.meanx,options.stdx]=calc_stdnorm(TrainSet.X);
   ValidSet.X = apply_stdnorm(ValidSet.X,options.meanx,options.stdx);
   TestSet.X  = apply_stdnorm(TestSet.X,options.meanx,options.stdx); 
   verbose(0,'\b\b\b\b. Done.\n');
end

if options.NOISE > 0
  verbose(0,'adding noise (%g) to training data ...',options.NOISE);
  maxabsX = mean(abs(TrainSet.X(:)));
  TrainSet.X = TrainSet.X+gaussrnd(0,options.NOISE*maxabsX,size(TrainSet.X,1),size(TrainSet.X,2));
  verbose(0,'\b\b\b\b. Done.\n');
end

if options.NOISY_DUPLICATES > 0
  verbose(0,'adding noisy duplicates (%i) to training data ...',options.NOISY_DUPLICATES);
  ri=ceil(rand(options.NOISY_DUPLICATES,1)*size(TrainSet.X,1));
  xd = TrainSet.X(ri,:);
  xd = xd+gaussrnd(0,options.NOISE*maxabsX,size(xd,1),size(xd,2));
  TrainSet.X = [TrainSet.X; xd];
  TrainSet.Y = [TrainSet.Y; TrainSet.Y(ri,:)];
  verbose(0,'\b\b\b\b. Done.\n');
end

range = sort(options.y_range);
verbose(0,'scaling target values into range [%g %g] ...',range(1),range(2));
for j=1:size(TrainSet.Y,2)
  ii=find(~isnan(TrainSet.Y(:,j)));
  b=min(TrainSet.Y(ii,j));
  TrainSet.Y(:,j) = TrainSet.Y(:,j)-b;
  a=max(TrainSet.Y(ii,j));
  if abs(a) < 1e-9
    error('all target values in the training set are equal (maxdiff=1e-9)!');
  end
  TrainSet.Y(:,j) = TrainSet.Y(:,j)/a*diff(range)+range(1);
  TestSet.Y(:,j)  = (TestSet.Y(:,j)-b)/a*diff(range)+range(1);
  ValidSet.Y(:,j) = (ValidSet.Y(:,j)-b)/a*diff(range)+range(1);
  options.a(j) = a;
  options.b(j) = b;
end
verbose(0,'\b\b\b\b. Done.\n');
