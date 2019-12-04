% load data 
%load('train_states.mat')
%load ('Labels.mat')

%Classification Config.
K = 10; % 10-fold cross-validation 

% Decision Trees 
tree = fitctree(X,Y);
cvmodel_DT = crossval(tree);
L_DT = kfoldLoss(cvmodel_DT);
sprintf('Accuracy of Testing DT is %0.2f \n',(1-L_DT)*100)

% Random forests.

% linear regression 
quadisc = fitcdiscr(X,Y,'DiscrimType','pseudoquadratic');
cvmodel_DA = crossval(quadisc,'kfold', 10);
L_DA = kfoldLoss(cvmodel_DA);
sprintf('Accuracy of Testing DT is %0.2f \n',(1-L_DA)*100)
X= dataset;
clear dataset
Y = 