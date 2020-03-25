
clear
clc
close all

wp_Parameters


[allFFT, Categories] = LoadAll(Paths.powerdata);
% plot mean BL, Pre, Post, S1, S2 of beam, whole spectrum of fz


Sessions = unique(Categories(3, :));
Sessions(strcmpi(Sessions, 'extras')) = [];
Sessions(contains(Sessions, 'Comp')) = [];
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
Sessions = {'BaselineBeam', 'Session1Beam', 'Session2Beam1', 'BaselineComp', 'Session1Comp', 'Session2Comp'};
Colors = {[ 1.00000  0.54118  0.83922], [ 1.00000  0.38039  0.83529], [ 0.85882  0.00000  0.60392], ...
    [ 0.00000  0.70196  0.74118], [ 0.00000  0.57255  0.65882], [  0.00000  0.47843  0.60000]};
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
        end
        
        plot(allFFT(1).Freqs, log(nanmean(All_Averages, 1)), 'Color', Colors{Indx_S}, 'LineWidth', 2)
    end
    legend(Sessions)
    title(['Power in Ch', num2str(Ch(Indx_Ch))])
    ylim([-3, 3])
    xlabel('Frequency (Hz)')
    ylabel('Power Density')
end


% plot topoplots


Freqs = [1:15];
Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1','Session2Beam2', 'Session2Beam3', 'MainPost'};
FreqsIndx =  dsearchn( allFFT(1).Freqs', Freqs');
load('StandardChanlocs128.mat')
Indx=1;
figure
for Indx_S = 1:numel(Sessions)
    for Indx_F = 1:numel(Freqs)

        All_Channels = nan(numel(Participants),size(allFFT(1).FFT.Channels, 1));
        Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
        
        for Indx_P = 1:numel(Session_Indexes)
            All_Channels(Indx_P, :) = mean(allFFT(Session_Indexes(Indx_P)).FFT.Epochs(:, FreqsIndx(Indx_F), :), 3);
        end
        
        subplot(numel(Sessions), numel(Freqs), Indx)
       
       topoplot(log(nanmean(All_Channels, 1)), StandardChanlocs, 'maplimits', [-2, 2], 'style', 'map', 'headrad', 'rim')
         Indx = Indx+1;
    end
end


%%%% range related stuff



% Theta_Range = [4;8];
% Freqs = allFFT(1).Freqs;
% ThetaIndx = dsearchn(Freqs', Theta_Range);


topoplot()
