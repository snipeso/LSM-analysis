
clear
clc
close all

wp_Parameters


[allFFT, Categories] = LoadAll(Paths.powerdata);
% plot mean BL, Pre, Post, S1, S2 of beam, whole spectrum of fz


Sessions = unique(Categories(3, :));
Sessions(strcmpi(Sessions, 'extras')) = [];
% Sessions(contains(Sessions, 'Comp')) = [];
Sessions = Sessions(contains(Sessions, 'Comp'));
Participants = unique(Categories(1, :));

figure
Ch = [10, 70];
for Indx_Ch = 1:numel(Ch)
    subplot(1, 2, Indx_Ch)
    hold on
for Indx_S = 1:numel(Sessions)
    All_Averages = nan(numel(Participants), numel(allFFT(1).Freqs));
     
       Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
        
    for Indx_P = 1:numel(Session_Indexes)
      All_Averages(Indx_P, :) = mean(allFFT(Session_Indexes(Indx_P)).FFT.Epochs(Ch(Indx_Ch), :, :), 3);
%        All_Averages(Indx_P, :) = allFFT(Session_Indexes(Indx_P)).FFT.Channels(70, :);
%         plot(allFFT(1).Freqs, log(All_Averages(Indx_P, :)), 'Color', [0.8 0.8 0.8])
    end
    
    plot(allFFT(1).Freqs, log(nanmean(All_Averages, 1)), 'LineWidth', 2)
end
legend(Sessions)
title(['Power in Ch', num2str(Ch(Indx_Ch))])
ylim([-3, 3])
xlabel('Frequency (Hz)')
ylabel('Power Density')
end

% 



% plot S1 and S2 of comp vs beam