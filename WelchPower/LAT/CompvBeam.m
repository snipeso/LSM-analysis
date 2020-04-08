




% % plot S1 and S2 of comp vs beam
% Sessions = {'BaselineBeam', 'Session1Beam', 'Session2Beam1', 'BaselineComp', 'Session1Comp', 'Session2Comp'};
% Colors = {[ 1.00000  0.54118  0.83922], [ 1.00000  0.38039  0.83529], [ 0.85882  0.00000  0.60392], ...
%     [ 0.00000  0.70196  0.74118], [ 0.00000  0.57255  0.65882], [  0.00000  0.47843  0.60000]};
% figure
% Ch = [10, 70];
% for Indx_H = 1:numel(Ch)
%     subplot(1, 2, Indx_H)
%     hold on
%     for Indx_S = 1:numel(Sessions)
%         All_Averages = nan(numel(Participants), numel(allFFT(1).Freqs));
%         Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
%         for Indx_P = 2:numel(Session_Indexes)
%             All_Averages(Indx_P, :) = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(Ch(Indx_H), :, :), 3);
%         end
%
%         plot(allFFT(1).Freqs, log(nanmean(All_Averages, 1)), 'Color', Colors{Indx_S}, 'LineWidth', 2)
%     end
%     legend(Sessions)
%     title(['Power in Ch', num2str(Ch(Indx_H))])
%     ylim([-2, 1.5])
%     xlim([1, 20])
%     xlabel('Frequency (Hz)')
%     ylabel('Power Density')
% end