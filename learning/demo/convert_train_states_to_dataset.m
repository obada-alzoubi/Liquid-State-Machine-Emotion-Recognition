% Converte train states into matrix
dataset =[];
for i = 1: length(train_states)
    dataset = [dataset ; train_states(i).X];
end