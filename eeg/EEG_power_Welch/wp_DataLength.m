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


PowerPath = fullfile(Paths.WelchPower, Task);
Sessions = Format.Labels.(Task).(Condition).Sessions;

Theta =  dsearchn( Freqs', Bands.Theta');


[RawData, Freqs, Chanlocs] = ChunkPower(PowerPath, Participants, Task, Sessions, Channels, Theta, Durations);




function [RawData, Freqs, Chanlocs] = ChunkPower(Path, Participants, Task, Sessions, Channels, Band, Durations)

RawData = struct();

% gather data
for Indx_P = 1:numel(Participants)
    %     SUM = zeros(1, numel(FreqsTot));
    %     SUMSQ = zeros(1, numel(FreqsTot));
    %     N = 0;
    
    AllFFT = [];
    
    for Indx_S =1:numel(Sessions)
        
        % load data
        Filename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'wp.mat'},'_');
        
        if ~exist(fullfile(Path, Filename), 'file')
            continue
        end
        
        load(fullfile(Path, Filename), 'Power')
        
        FFT = Power.FFT;
        Freqs = Power.Freqs;
        Chanlocs = Power.Chanlocs;
        Edges = Power.Edges;
        
        AllFFT = cat(3, AllFFT, FFT);
        
        
    end
    
    % get powerpeaks for hotspot
    Indexes_Hotspot = ismember( str2double({Chanlocs.labels}), Channels);
    
    srate = 1/(Edges(2)-Edges(1));
    TotDur = size(AllFFT, 3);
    
    
    for Indx_D = 1:numel(Durations)
        D = Durations(Indx_D);
        
        Starts = 1:D*srate:TotDur;
        
        for Indx_S = 1:numel(Starts)-1
            S = Starts(Indx_S);
            E = Starts(Indx_S +1);
            
            if E-S < D*srate
                Power = [];
                Participant = [];
            else
                Power = nanmean(nanmean(nanmean(AllFFT(Indexes_Hotspot, Band(1):Band(2), S:E),2), 1), 3);
                Participant = Indx_P;
            end
            
            
            if ~isfield(RawData, 'Power')
                RawData.(['D', num2str(D)]).Power = Power;
                RawData.(['D', num2str(D)]).Participant = Participant;
            end
            RawData.(['D', num2str(D)]).Power = ...
                cat(2, RawData.(['D', num2str(D)]).Power, Power);
            
            RawData.(['D', num2str(D)]).Participant = ...
                cat(2, RawData.(['D', num2str(D)]).Participant, Participant);
            
        end
        
        % save
        %         RawData.(['D', num2str(D)])(Indx_P, Indx_S, 1:numel(Freqs)) = squeeze(nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 3),1));
        
        
        %          SUM =SUM + squeeze(nansum(nanmean(FFT, 3), 1)); % sum windows and channels
        %         SUMSQ = SUMSQ + squeeze(nansum(nanmean(FFT, 3).^2, 1));
        %         N = N + nnz(~isnan(reshape(nanmean(FFT(:, 1, :),3), 1, [])));
    end
end




end