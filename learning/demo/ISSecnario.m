function [ output_args ] = ISSecnario( X, Y, L )
% 
Nsubj = 32;
Nvid = 40;

%Build filter for indices 
f = [];
for i = 1:Nsubj
    f = [ f ; repmat(i, Nvid, 1)];
end
% Loop over subjects
for sub = 1 : Nsubj
    % Loop over videos
    for vid = 1: Nvid
        ind = (sub -1)*Nvid + vid;
        X_sub = [];
        Y_sub = [];
        if f(ind) == sub
          X_sub = [X_sub ; X(ind).data];
          Y_sub = [Y_sub ; repmat(Y(ind), L, 1)];
        end
               
    end
    % Classifier 
    sub_results = classify_DT_DA(X_sub, Y_sub);
end


end


