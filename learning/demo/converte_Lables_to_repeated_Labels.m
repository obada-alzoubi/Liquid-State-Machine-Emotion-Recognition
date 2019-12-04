% convert labels into repeated labels 
L = 149 ; % Liquid states per sample
repLabels = [];
for i = 1:size(Labels,1)
    l = repmat(Labels(i,:), L, 1);
    repLabels = [repLabels; l];
end