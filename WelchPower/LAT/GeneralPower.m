
clear
clc
close all

wpLAT_Parameters


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Scaling = 'norm'; % either 'log' or 'norm'

% Sessions = allSessions.Comp;
% SessionLabels = allSessionLabels.Comp;
% SessionsTitle = 'Comp';

Sessions = allSessions.LAT;
SessionLabels = allSessionLabels.LAT;
SessionsTitle = 'Beam';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch Scaling
    case 'log'
        for Indx_F = 1:size(allFFT, 2)
            allFFT(Indx_F).FFT = log(allFFT(Indx_F).FFT);
        end
        YLabel = 'Power Density';
        YLims = [-2.5, 0.5];
    case 'norm'
        load(fullfile(Paths.wp, 'wPower', 'LAT_FFTnorm.mat'), 'normFFT')
        allFFT = normFFT;
        YLabel = '% Change from Pre';
end
TitleTag = [Scaling, SessionsTitle];

PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);


figure( 'units','normalized','outerposition',[0 0 .5 .5])
Colors = {[ 0.00000  0.43922  0.36863], ... %BL
    [1.00000  0.61961  0.38039], ... % pre
    [ 1.00000  0.78039  0.80392], ... %session1
    [ 1.00000  0.60000  0.72157], ... %s2B1
    [ 1.00000  0.34118  0.58039], ... %s2b2
    [  0.80000  0.00000  0.46667], ... %S2b3
    [0.58039  0.00000  0.61961],... % post
    };

plotChannels = [3:7, 9:13, 15, 16, 18:20, 24, 106, 111, 112, 117, 118, 123, 124]; % hotspot
ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);
Title = 'HotSpot';

for Indx_H = 1:2
    if Indx_H == 2
        ChanIndx = ~ismember( str2double({Chanlocs.labels}), plotChannels); % not hotspot
        Title =  'Not HotSpot';
    end
    
    subplot(1, 2, Indx_H)
    hold on
    for Indx_S = 1:numel(Sessions)
        All_Averages = nan(numel(Participants), numel(Freqs));
        
        for Indx_P = 1:numel(Participants)
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            All_Averages(Indx_P, :) = nanmean(nanmean(PowerStruct(Indx_P).(Sessions{Indx_S})(ChanIndx, :, :), 1), 3);
        end
        
        plot(Freqs, nanmean(All_Averages, 1), 'LineWidth', 2, 'Color', Colors{Indx_S})
    end
    legend(Sessions)
    title(['Power in ', Title])
    ylim(YLims)
    xlim([1, 20])
    xlabel('Frequency (Hz)')
    ylabel('Power Density')
end
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_LAT_Power.svg']))


% plot topoplots
plotFreqs = [2:2:20];
FreqsIndx =  dsearchn( Freqs', plotFreqs');

Indx=1;
figure( 'units','normalized','outerposition',[0 0 1 1])
for Indx_S = 1:numel(Sessions)
    for Indx_F = 1:numel(FreqsIndx)
        
        All_Channels = nan(numel(Participants), numel(Chanlocs));
        
        for Indx_P = 1:numel(Participants)
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            All_Channels(Indx_P, :) = nanmean(PowerStruct(Indx_P).(Sessions{Indx_S})(:, FreqsIndx(Indx_F), :), 3);
        end
        subplot(numel(Sessions), numel(FreqsIndx), Indx)
        topoplot(nanmean(All_Channels, 1), Chanlocs, 'maplimits', YLims, 'style', 'map', 'headrad', 'rim')
        
        %         if Indx<=numel(FreqsIndx)
        %             title([num2str(plotFreqs(Indx_F)), 'Hz'])
        %         end
        title([SessionLabels{Indx_S}, ' ' num2str(plotFreqs(Indx_F)), 'Hz'])
        Indx = Indx+1;
        
    end
end
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_LAT_PowerTopo.svg']))



% plot distribution flame plots
plotFreqs = [3 7 10 18];
FreqsIndx =  dsearchn( Freqs', plotFreqs');

ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);
Title = 'HotSpot';

for Indx_H = 1:2
    if Indx_H == 2
        ChanIndx = ~ismember( str2double({Chanlocs.labels}), plotChannels); % not hotspot
        Title =  'Not HotSpot';
    end
    
    figure( 'units','normalized','outerposition',[0 0 1 1])
    for Indx_F = 1:numel(FreqsIndx)
        subplot(2, 2, Indx_F)
        PlotPowerFlames(PowerStruct, ChanIndx, FreqsIndx(Indx_F), Sessions, SessionLabels)
        title([Title, ' ', num2str(plotFreqs(Indx_F)), 'Hz Distribution'])
        ylabel(YLabel)
        ylim([-4, 4])
    end
    saveas(gcf,fullfile(Paths.Figures, [TitleTag,'_', Title, '_LAT_Flames.svg']))
    
end


% plot spaghetti plot of 4 frequencies


ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);
Title = 'HotSpot';

for Indx_H = 1:2
    if Indx_H == 2
        ChanIndx = ~ismember( str2double({Chanlocs.labels}), plotChannels); % not hotspot
        Title =  'Not HotSpot';
    end
    
    figure( 'units','normalized','outerposition',[0 0 1 1])
    for Indx_F = 1:numel(FreqsIndx)
          All_Averages = nan(numel(Participants), numel(Sessions));
        for Indx_S = 1:numel(Sessions)
          
            
            for Indx_P = 1:numel(Participants)
                if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                    continue
                end
                All_Averages(Indx_P, Indx_S) = nanmean(nanmean(PowerStruct(Indx_P).(Sessions{Indx_S})(ChanIndx, FreqsIndx(Indx_F), :), 1), 3);
            end
        end
        
        subplot(2, 2, Indx_F)
        PlotConfettiSpaghetti(All_Averages, Sessions, SessionLabels, [min(All_Averages(:)), max(All_Averages(:))], ...
            [Title, ' ', num2str(plotFreqs(Indx_F)), 'Hz Power'], [])
        
        ylabel(YLabel)
    end
        saveas(gcf,fullfile(Paths.Figures, [TitleTag,'_', Title, '_LAT_SessionPowerChange.svg']))
    
end



