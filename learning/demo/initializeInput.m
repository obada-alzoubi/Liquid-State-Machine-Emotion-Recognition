function [ Input ] = initializeInput( Data, Tstim )
% Initialize the input to LSM 

for subj = 1 : length(Data)
    for vid =1 : 40
        for ch = 1 : 32 
            % channel 
            Input((subj -1)*40 + vid).channel(ch).data = Data(subj).video(vid).data(ch,:);
            % Spiking information
            Input((subj -1)*40 + vid).channel(ch).spiking  = 0;
            % dt information
            Input((subj -1)*40 + vid).channel(ch).dt =1;
        end
        % Info information 
        Input((subj -1)*40 + vid).info.Tstim = Tstim;
        Input((subj -1)*40 + vid).info.actualTemplate = 0;
        
    end
    
end 

end

