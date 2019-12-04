function [ Data ] = loadDEAP()

for i = 1:32 
    subject = sprintf('s%02d.mat',i);
    % Load data 
    load(subject);
    % Load video information
    for j=1:40
        video = squeeze(data(j, :, :));
        label = labels(j, :, : );
        v = 1; % Valence
        a = 1; % arousal 
        d = 1; % dominance
        l = 1; % liking;
        if label(1) < 5 
            v = 0;
        end
        if label(2) < 5
            a = 0;
        end
        if label(3) < 5
            d = 0;
        end
        if label(3) < 5
            l = 0;
        end
        Data(i).video(j).data = video ;
        Data(i).video(j).label= [v a d l];
        
    end
end 

end

