
clear
clc
close all

wpLAT_Parameters


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Scaling = 'log'; % either 'log' or 'norm'

Sessions = allSessions.Comp;
SessionLabels = allSessionLabels.Comp;
SessionsTitle = 'Comp';
SessionsSmall = {'BaselineComp', 'Session2Comp'};
SessionsSmallLabels = {'BL', 'S2'};

% Sessions = allSessions.LAT;
% SessionLabels = allSessionLabels.LAT;
% SessionsTitle = 'Beam';
% SessionsSmall = {'MainPre', 'Session2Beam2'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch Scaling
    case 'log'
        for Indx_F = 1:size(allFFT, 2)
            allFFT(Indx_F).FFT = log(allFFT(Indx_F).FFT + 1);
        end
        YLabel = 'Power Density';
        
    case 'norm'
        load(fullfile(Paths.wp, 'wPower', 'LAT_FFTnorm.mat'), 'normFFT')
        allFFT = normFFT;
        YLabel = '% Change from Pre';
        
end
TitleTag = [Scaling, SessionsTitle];

PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);


% get limits per participant
Quantiles = zeros(numel(Participants), numel(Sessions), 2);
for Indx_P = 1:numel(Participants)
    
    
    for Indx_S = 1:numel(Sessions)
        A = PowerStruct(Indx_P).(Sessions{Indx_S});
        Quantiles(Indx_P, Indx_S, 1) =  quantile(A(:), .05);
        Quantiles(Indx_P, Indx_S, 2) =  quantile(A(:), .95);
    end
end

CLimsInd = [min(Quantiles(:, :, 1),[],  2), max(Quantiles(:, :, 2),[],  2)];


plotChannels = [3:7, 9:13, 15, 16, 18:20, 24, 106, 111, 112, 117, 118, 123, 124]; % hotspot


% plot time x freq of recordings TODO: move?


YLimFreq = [4 14];
ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);
NotChanIndx =  ~ismember( str2double({Chanlocs.labels}), plotChannels); % not hotspot
Title = 'HotSpot';

for Indx_H = 1:2
    if Indx_H == 1
        finalChanIndx = ChanIndx;
        Title =  'HotSpot';
    else
        finalChanIndx = NotChanIndx;
        Title =  'Not HotSpot';
    end
    
    figure( 'units','normalized','outerposition',[0 0 1 1])
    
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            A = PowerStruct(Indx_P).(Sessions{Indx_S});
            subplot(numel(Participants), numel(Sessions), numel(Sessions) * (Indx_P - 1) + Indx_S )
            
            PlotSessionFreqs(squeeze(nanmean(A(finalChanIndx, :, :), 1)), YLimFreq, CLimsInd(Indx_P, :), Freqs )
            title([Participants{Indx_P}, ' ', Title, ' ', Sessions{Indx_S}])
        end
        
    end
    saveas(gcf,fullfile(Paths.Figures, [TitleTag,'_', Title, '_LAT_TimeFreq.svg']))
end


YLimFreq = [2 20];

for Indx_P = 1:numel(Participants)
    figure( 'units','normalized','outerposition',[0 0 .5 .5])
    
    for Indx_S = 1:numel(SessionsSmall)
        subplot(2,numel(SessionsSmall), Indx_S)
        A = PowerStruct(Indx_P).(SessionsSmall{Indx_S});
        PlotSessionFreqs(squeeze(nanmean(A(ChanIndx, :, :), 1)), YLimFreq, CLimsInd(Indx_P, :), Freqs )
        title([Participants{Indx_P}, ' Hotspot ', SessionsSmallLabels{Indx_S}])
        colorbar
        subplot(2,numel(SessionsSmall), numel(SessionsSmall)+ Indx_S)
        A = PowerStruct(Indx_P).(SessionsSmall{Indx_S});
        PlotSessionFreqs(squeeze(nanmean(A(NotChanIndx, :, :), 1)), YLimFreq, CLimsInd(Indx_P, :), Freqs )
        title([Participants{Indx_P}, ' NotHotspot ', SessionsSmallLabels{Indx_S}])
        colorbar
    end
    
    saveas(gcf,fullfile(Paths.Figures, [TitleTag,'_', Participants{Indx_P}, '_LAT_TimeFreq.svg']))
end