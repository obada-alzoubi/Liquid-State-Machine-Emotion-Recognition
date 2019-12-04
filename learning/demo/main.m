startup;
VERBOSE_LEVEL = 0; % the higher the more is printed at stdout
PLOTTING_LEVEL = 0; % the gigher the more plots will appear
% define the input distribution
Tmax = 60;
nInputChannels= 32; % EEG Input

% Build the LSM 
% LSM architecture and connection configuration is located in make_liquid
make_liquid_EEG

[ Data ] = loadDEAP();

% Generate the input that is suitable for LSM 
[ S ] = initializeInput( Data, Tmax );

%clear Data
clear Data

% Generate stimulus 
[train_response,~] = collect_sr_data(nmc,S,32*40);

%Clear S
clear S

save('train_response.mat','train_response','-v7.3')

clear train_response
% Get liquid states 
train_states  = response2states(train_response, [], [0.5:0.4:Tmax]); 
save('train_states.mat','train_states','-v7.3')
convert_train_states_to_dataset
clear train_states
save('dataset.mat','dataset','-v7.3')
converte_Lables_to_repeated_Labels
save('repLabels.mat','repLabels','-v7.3')
 Y= repLabels(:,1);
 
 % Classify 
 % Decision Trees 
tree = fitctree(X,Y);
cvmodel_DT = crossval(tree);
L_DT = kfoldLoss(cvmodel_DT);
sprintf('Accuracy of Testing DT is %0.2f \n',(1-L_DT)*100)



