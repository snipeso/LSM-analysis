
clear
clc
close all

LAT_Parameters

 

load('LATAnswers.mat', 'AllAnswers')


% Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
% SessionLabels = {'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'};

% Sessions = {'BaselineComp', 'Session1Comp', 'Session2Comp',};
% SessionLabels = {'BLc', 'S1c', 'S2c',};

Sessions = {'BaselineBeam', 'Session1Beam', 'Session2Beam1',};
SessionLabels = {'BLb', 'S1b', 'S2b1',};


Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07'};

figure
hold on
MeanRTs = nan(numel(Participants), numel(Sessions));
stdRTs = nan(numel(Participants), numel(Sessions));

Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
    ones(numel(Participants), 1), ...
   ones(numel(Participants), 1)];
Colors = hsv2rgb(Colors);
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        
        RTs = cell2mat(AllAnswers.rt(strcmp(AllAnswers.Session, Sessions{Indx_S}) & ...
            strcmp(AllAnswers.Participant, Participants{Indx_P})));
        RTs(isnan(RTs)) = [];
        RTs(RTs < 0.1) = [];
        if size(RTs, 1) < 1
            continue
        end
        MeanRTs(Indx_P, Indx_S) = mean(RTs);
        stdRTs(Indx_P, Indx_S) = std(RTs);
        violin(RTs, 'x', [Indx_S, 0], 'facecolor', Colors(Indx_P, :), ...
            'edgecolor', [], 'facealpha', 0.1, 'mc', [], 'medc', []);
    end
end
title('Reaction Time Distributions')
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylabel('RT (s)')
ylim([0.1, 1])


figure
hold on
Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
    ones(numel(Participants), 1)*0.2, ...
   ones(numel(Participants), 1)];
Colors = hsv2rgb(Colors);
for Indx_P = 1:numel(Participants)
    plot(MeanRTs(Indx_P, :), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
end

plot(nanmean(MeanRTs, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
title('Reaction Time Means')
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylabel('RT (s)')
ylim([0.3, 0.6])


figure
hold on
Color = [0.7, 0.7, 0.7];
for Indx_P = 1:numel(Participants)
    plot(stdRTs(Indx_P, :), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
end

plot(nanmean(stdRTs, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
title('Reaction Time Standard Deviations')
xlim([0, numel(Sessions) + 1])
xticks(1:numel(Sessions))
xticklabels(SessionLabels)
ylabel('RT SD (s)')


% 
% figure
% 
% 
% 
% 
% 
% 
% 
% 
% 
% figure
% hold on
% Freqs = [1:20];
% FreqIndx =  dsearchn( allFFT(1).Freqs', Freqs');
% allAverages = nan(numel(Freqs), numel(Sessions));
% %TODO: get colors
% Colors = colormap(flipud(jet(numel(Freqs))));
% for Indx_F = 1:numel(Freqs)
%     for Indx_S = 1:numel(Sessions)
%         pAverages = nan(numel(Participants), nnz(ChanIndx));
%         Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
%         
%         for Indx_P = 4%1:numel(Session_Indexes)
%             %              pAverages(Indx_P, :) = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(ChanIndx, Indx_F, :), 3)';
%             pAverages(Indx_P, :) = nanmean(normFFT(Session_Indexes(Indx_P)).FFT(ChanIndx, Indx_F, :), 3)';
%         end
%         
%         %         allAverages(Indx_F, Indx_S) = log(nanmean(nanmean(pAverages, 1)));
%         allAverages(Indx_F, Indx_S) = nanmean(nanmean(pAverages, 1));
%     end
%     plot(allAverages(Indx_F,:), 'o-', 'Color', Colors(Indx_F, :), 'LineWidth', 3)
% end
% xticks(1:7)
% xticklabels({'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'})
% 
% MeanAll = mean(mean(allAverages));
% StdAll = std(mean(allAverages));
% % YLims = [min(allAverages(:)), max(allAverages(:))];
% YLims = [-15, 100];
% plot(repmat(1:7, 2, 1), repmat(YLims, 7, 1)', 'k', 'LineWidth', 2)
% ylim(YLims)
% xlim([0, 8])
% title('NotHotSpot Frequency Change (relative to Pre)')
% ylabel('% Change Power Density')
% c = colorbar;
% caxis([min(Freqs), max(Freqs)])
% 
% c.Label.String = 'Frequencies (Hz)';
% % c.Label.FontSize = 10;
% % % ylabel('% Change from Pre')
% 
% set(findall(gcf,'-property','FontSize'),'FontSize',12)