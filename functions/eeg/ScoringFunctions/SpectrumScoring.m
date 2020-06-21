function [Delta, VI30] = SpectrumScoring(Data, srate)
%%% Code taken from Sven Leach and Elena Krugliakova. Calculates delta
%%% power across the night, and also this magic Vigilence Index that is
%%% helpful. 

% number of 4s epochs in the data
pnts = size(Data, 2);
bins = floor(pnts/srate/4);  

% preallocate to boost speed
Delta = NaN(30, bins);
sp2 = NaN(4,  bins);


wb = waitbar(0, 'Spectral power analysis ...');
for Epoch = 1:bins
    
    % sample points in each 4s window
    from = (Epoch-1)*4*srate+1;
    to = (Epoch-1)*4*srate+4*srate;
    
    % spectral analysis in 4s windows (just as the scoring programm needs it)
    % with a hanning window, zero overlap, for 1 to 512 Hz bins, and
    % specify the sampling rate.
    [fft_epoch, freq] = pwelch(Data(from:to), hanning(4*srate), 0, 4*srate, srate);
    
    % frequencies of interest
    index30 = freq<30;
    index4  = freq>=0.5 & freq<=4;
    index16 = freq>=11  & freq<=16;
    index13 = freq>=8   & freq<=13;    
    index40 = freq>=20  & freq<=40;
      
    % take power values for frequencies up to 30 Hz (ffte(1:120) and
    % take the mean of 4 neoughbouring frequency bins eachs (still only 
    % up to 30 Hz). Must have 30 rows, corresponds to one power-bar in a 
    % 4s window in the scoring programm
    fft30  = mean(reshape(fft_epoch(index30), 4, 30)); 
      
    % Power in delta, sigma, alpha and beta-gamma range (needed for the
    % vigilance index, which is stored in .sp2.
    sp2(1, Epoch) = mean(fft_epoch(index4));    % delta
    sp2(2, Epoch) = mean(fft_epoch(index16));   % sigma (spindles)
    sp2(3, Epoch) = mean(fft_epoch(index13));   % alpha
    sp2(4, Epoch) = mean(fft_epoch(index40));   % beta-gamma
                                                                                                                                                  
    % concatenate 4s epochs.
    Delta(:, Epoch) = fft30;
    waitbar(Epoch/bins, wb, 'Spectral power analysis ...');
end  
close(wb)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Vigilence index

% Calculate modified Vigilance Index (with emphasis on spindles). The idea
% came from Elena Krugliakova (thank you!). It is based on this article:
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5455770/?fbclid=IwAR22XbpTGq2LsOiQGeNwZujvLiZ_aNGvFPwn65iAClTAn5yUgtMjFYQiPbg
% VI = [delta power norm + 2*spindle power norm] / ...
%      [alpha power norm + high-beta power norm]
% Frequency ranges used were delta (1–4 Hz),  spindle (11–16Hz), 
%                            alpha (8–13 Hz), high-beta (20–40 Hz)   

VI = (sp2(1,:)./median(sp2(1,:))  +  sp2(2,:)./median(sp2(2,:)).*2) ./ ...
         (sp2(3,:)./median(sp2(3,:))  +  sp2(4,:)./median(sp2(4,:)));     

% Reshape VI, so that each 4s epoch has the same value 30x (otherwise the
% scoring programm cannot read it).
VI30 = repmat(VI, 30, 1);


%%% TODO: rename variables to things a little more meaningful.
 