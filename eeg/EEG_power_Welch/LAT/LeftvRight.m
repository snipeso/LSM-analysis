


% plot sides
% Freqs = [1:15];
% Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1','Session2Beam2', 'Session2Beam3', 'MainPost'};
% FreqsIndx =  dsearchn( allFFT(1).Freqs', Freqs');
%
% for Indx_L = 1:2
%     Indx=1;
%     figure
%     for Indx_S = 1:numel(Sessions)
%         for Indx_F = 1:numel(Freqs)
%
%             All_Channels = nan(numel(Participants),size(allFFT(1).FFT, 1));
%             Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
%
%             for Indx_P = 1:numel(Session_Indexes)
%                 All_Channels(Indx_P, :) = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(:, FreqsIndx(Indx_F), (allFFT(Session_Indexes(Indx_P)).Blocks ==Indx_L)), 3);
%             end
%             subplot(numel(Sessions), numel(Freqs), Indx)
%             topoplot(log(nanmean(All_Channels, 1)), allFFT(1).Chanlocs, 'maplimits', [-2, 1.5], 'style', 'map', 'headrad', 'rim')
%             Indx = Indx+1;
%             if Indx<=numel(Freqs)
%                 title([num2str(Freqs(Indx_F)), 'Hz'])
%             end
%         end
%     end
%
% end
%
% % plot difference
% Freqs = [1:15];
% Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1','Session2Beam2', 'Session2Beam3', 'MainPost'};
% FreqsIndx =  dsearchn( allFFT(1).Freqs', Freqs');
%
%
% Indx=1;
% figure
% for Indx_S = 1:numel(Sessions)
%     for Indx_F = 1:numel(Freqs)
%
%         All_Channels = nan(numel(Participants),size(allFFT(1).FFT, 1));
%         Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
%
%         for Indx_P = 2:numel(Session_Indexes)
%             LeftTopo = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(:, FreqsIndx(Indx_F), (allFFT(Session_Indexes(Indx_P)).Blocks ==1)), 3);
%             RightTopo = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(:, FreqsIndx(Indx_F), (allFFT(Session_Indexes(Indx_P)).Blocks ==2)), 3);
%             All_Channels(Indx_P, :) = (log(LeftTopo)-log(RightTopo))./log(RightTopo);
%         end
%         subplot(numel(Sessions), numel(Freqs), Indx)
%         topoplot(nanmean(All_Channels, 1), allFFT(1).Chanlocs, 'maplimits', [-.2, .2], 'style', 'map', 'headrad', 'rim')
%         Indx = Indx+1;
%         if Indx<=numel(Freqs)
%             title([num2str(Freqs(Indx_F)), 'Hz'])
%         end
%     end
% end
