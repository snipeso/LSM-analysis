% plot scatter violins of theta for different lengths of data
% highlight first and last block. % color scatters for individuals (also jitter);
% blackspots for mean
% also effect size change

clear
clc
close all

wp_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'LAT';
Condition = 'SD';
ReferenceSession = 'BaselineBeam';

Durations = [1 2 5 7 10 15 30 45];

Channels = EEG_Channels.Hotspot;
Normalization = ''; % none, zscore, log, white
ToPlot = false; % individual spectrums

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RawData = struct();

% gather data
for Indx_P = 1:numel(Prticipants)
    SUM = zeros(1, numel(FreqsTot));
    SUMSQ = zeros(1, numel(FreqsTot));
    N = 0;
    
     for Indx_S =1:numel(Sessions)
        
        % load data
        Filename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'wp.mat'},'_');
        
        if ~exist(fullfile(PowerPath, Filename), 'file')
            continue
        end
        
        load(fullfile(PowerPath, Filename), 'Power')
        
        FFT = nanmean(Power.FFT, 3);
        Freqs = Power.Freqs;
        Chanlocs = Power.Chanlocs;
        
        
        % get powerpeaks for hotspot
        Indexes_Hotspot = ismember( str2double({Chanlocs.labels}), Channels);
        
        
        
        % save
        RawData(Indx_P, Indx_S, 1:numel(Freqs)) = squeeze(nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 3),1));
        
         SUM =SUM + squeeze(nansum(nanmean(FFT, 3), 1)); % sum windows and channels
        SUMSQ = SUMSQ + squeeze(nansum(nanmean(FFT, 3).^2, 1));
        N = N + nnz(~isnan(reshape(nanmean(FFT(:, 1, :),3), 1, [])));
    
     end
    
    
end