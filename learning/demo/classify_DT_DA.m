function [ results ] = classify_DT_DA( X, Y )

results = zeroes(size(Y,2), 2);
for labels = 1 : size(Y,2)
    % Print some details 
    switch labels
        case 1
            sprintf('Valence \n')
        case 2
            sprintf('Arousal \n')
        case 3
            sprintf('Dominance \n')
        case 4
            sprintf('Liking \n')
    end
    
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

results(labels) = [L_DT L_DA];
end

end

