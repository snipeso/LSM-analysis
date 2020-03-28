% clear
% clc
% close all
% 
% wp_Parameters
% 
% 
% [allFFT, Categories] = LoadAll(Paths.powerdata);
% Chanlocs = allFFT(1).Chanlocs;

Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
Participants = unique(Categories(1, :));
ChanLabels = {Chanlocs.labels};
Channels = size(Chanlocs, 2);
Colors = MapRainbow([Chanlocs.X], [Chanlocs.Y], [Chanlocs.Z], true);

normFFT = allFFT;
for Indx_P = 1:numel(Participants)
    for Indx_Ch = 1:Channels
        BL_Indx = find(strcmp(Categories(1, :),Participants{Indx_P}) & strcmp(Categories(3, :), 'MainPre'));
        BL = nanmean(allFFT(BL_Indx).FFT(Indx_Ch, :, :), 3);
        
        for Indx_S = 1:numel(Sessions)
            F_Indx =  find(strcmp(Categories(1, :),Participants{Indx_P}) & strcmp(Categories(3, :), Sessions{Indx_S}));
            if isempty(F_Indx)
                if Indx_Ch == 1
               disp(['**************Skipping ', Participants{Indx_P},  Sessions{Indx_S}, '*****************'])
                end
               continue
            end
            S = squeeze(allFFT(F_Indx).FFT(Indx_Ch, :, :));
            normFFT(F_Indx).FFT(Indx_Ch, :, :) = 100*((S-BL')./BL');
        end
    end
end




figure
hold on
allAverages = nan(Channels, numel(Sessions));
Freq = 7;
FreqIndx =  dsearchn( allFFT(1).Freqs', Freq);
for Indx_Ch = 1:Channels
    for Indx_S = 1:numel(Sessions)
        pAverages = nan(numel(Participants), 1);
        Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
        
        for Indx_P = 1:numel(Session_Indexes)
            pAverages(Indx_P) = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(Indx_Ch, FreqIndx, :), 3);
%             pAverages(Indx_P) = nanmean(normFFT(Session_Indexes(Indx_P)).FFT(Indx_Ch, FreqIndx, :), 3);
        end
        
        allAverages(Indx_Ch, Indx_S) = log(nanmean(pAverages));
%         allAverages(Indx_Ch, Indx_S) = nanmean(pAverages);
    end
    plot(allAverages(Indx_Ch,:), 'Color', Colors(Indx_Ch, :), 'LineWidth', 1)
end
xticks(1:7)
xticklabels({'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'})

MeanAll = mean(mean(allAverages));
StdAll = std(mean(allAverages));
% YLims = [MeanAll-3*StdAll,MeanAll+3*StdAll];
YLims = [-.8, 1.6];
plot(repmat(1:7, 2, 1), repmat(YLims, 7, 1)', 'k', 'LineWidth', 2)
ylim(YLims)
xlim([0, 8])
ylabel('Theta Power Density')
% ylabel('% Change Theta from Pre')

figure
for Indx_S = 1:size(allAverages, 2)
    subplot(1, size(allAverages, 2), Indx_S)
     topoplot(allAverages(:, Indx_S), Chanlocs, 'maplimits', YLims, 'style', 'map', 'headrad', 'rim')
     title(Sessions{Indx_S})
end

%% frequency


figure
hold on
allAverages = nan(Channels, numel(Sessions));
Freqs = 1:20;
FreqIndx =  dsearchn( allFFT(1).Freqs', Freqs);
for Indx_F = 1:Channels
    for Indx_S = 1:numel(Sessions)
        pAverages = nan(numel(Freqs), 1);
        Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
        
        for Indx_P = 1:numel(Session_Indexes)
            pAverages(Indx_P) = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(:, FreqIndx, :), 3);
%             pAverages(Indx_P) = nanmean(normFFT(Session_Indexes(Indx_P)).FFT(Indx_Ch, FreqIndx, :), 3);
        end
        
        allAverages(Indx_Ch, Indx_S) = log(nanmean(pAverages));
%         allAverages(Indx_Ch, Indx_S) = nanmean(pAverages);
    end
    plot(allAverages(Indx_Ch,:), 'Color', Colors(Indx_Ch, :), 'LineWidth', 1)
end
xticks(1:7)
xticklabels({'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'})

MeanAll = mean(mean(allAverages));
StdAll = std(mean(allAverages));
% YLims = [MeanAll-3*StdAll,MeanAll+3*StdAll];
YLims = [-.8, 1.6];
plot(repmat(1:7, 2, 1), repmat(YLims, 7, 1)', 'k', 'LineWidth', 2)
ylim(YLims)
xlim([0, 8])
ylabel('Theta Power Density')
% ylabel('% Change Theta from Pre')
