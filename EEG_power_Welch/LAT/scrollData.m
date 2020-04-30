
clear
clc
close all

wpLAT_Parameters

Participant = 2;
Session = 'Session2Beam1';
Baseline = 'MainPost';
Channel = 11;
Frequency = 6;
YLims = [-2 2];
YLims_Change = [-150, 150];


FreqsIndx =  dsearchn( Freqs', Frequency);
Sessions = allSessions.LAT;

for Indx_F = 1:size(allFFT, 2)
    allFFT(Indx_F).FFT = log(allFFT(Indx_F).FFT);
end

PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);
BL = PowerStruct(Participant).(Baseline);
SD = PowerStruct(Participant).(Session);

figure
subplot(1, 2, 1)
histogram(BL(Channel, Frequency, :))
title('BL theta')
subplot(1, 2, 2)
histogram(SD(Channel, Frequency, :))
title('Session theta')

% find 95% quantile of BL, use as threshold
Threshold = quantile(BL(Channel, Frequency, :), .95);

BLevents = squeeze(BL(Channel, Frequency, :)) > Threshold;
SDevents = squeeze(SD(Channel, Frequency, :)) > Threshold;

% plot topoplot of above threshold windows for 3, 6, 10, 15 and 20 Hz
plotFreqs = [2:2:20];
FreqsIndx =  dsearchn( Freqs', plotFreqs');

figure( 'units','normalized','outerposition',[0 0 1 .5])
for Indx_F = 1:numel(FreqsIndx)
    subplot(2, numel(FreqsIndx), Indx_F)
    topoplot(nanmean(BL(:, FreqsIndx(Indx_F), BLevents), 3), Chanlocs, 'maplimits', YLims, 'style', 'map', 'headrad', 'rim')
    title(['Peak BL ', num2str(plotFreqs(Indx_F)), 'Hz'])
    
    subplot(2,numel(FreqsIndx),numel(FreqsIndx)+ Indx_F)
    topoplot(nanmean(SD(:, FreqsIndx(Indx_F), SDevents), 3), Chanlocs, 'maplimits', YLims, 'style', 'map', 'headrad', 'rim')
    title(['Peak SD ', num2str(plotFreqs(Indx_F)), 'Hz'])
end
colormap('magma')

figure( 'units','normalized','outerposition',[0 0 1 .5])
for Indx_F = 1:numel(FreqsIndx)
    subplot(2, numel(FreqsIndx), Indx_F)
    topoplot(nanmean(BL(:, FreqsIndx(Indx_F), ~BLevents), 3), Chanlocs, 'maplimits', YLims, 'style', 'map', 'headrad', 'rim')
    title(['Rest BL ', num2str(plotFreqs(Indx_F)), 'Hz'])
    
    subplot(2,numel(FreqsIndx),numel(FreqsIndx)+ Indx_F)
    topoplot(nanmean(SD(:, FreqsIndx(Indx_F), ~SDevents), 3), Chanlocs, 'maplimits', YLims, 'style', 'map', 'headrad', 'rim')
    title(['Rest SD ', num2str(plotFreqs(Indx_F)), 'Hz'])
end
colormap('magma')

% difference between peak and not peak events
figure( 'units','normalized','outerposition',[0 0 1 .5])
for Indx_F = 1:numel(FreqsIndx)
    subplot(2, numel(FreqsIndx), Indx_F)
    BL_diff = 100*(nanmean(BL(:, FreqsIndx(Indx_F), BLevents), 3) - nanmean(BL(:, FreqsIndx(Indx_F), ~BLevents), 3))./nanmean(BL(:, FreqsIndx(Indx_F), ~BLevents), 3);
    topoplot(BL_diff, Chanlocs, 'maplimits', YLims_Change, 'style', 'map', 'headrad', 'rim')
    title(['Diff BL ', num2str(plotFreqs(Indx_F)), 'Hz'])
    
    subplot(2,numel(FreqsIndx),numel(FreqsIndx)+ Indx_F)
    SD_diff = 100*(nanmean(SD(:, FreqsIndx(Indx_F), SDevents), 3) - nanmean(SD(:, FreqsIndx(Indx_F), ~SDevents), 3))./nanmean(BL(:, FreqsIndx(Indx_F), ~BLevents), 3);
    topoplot(SD_diff, Chanlocs, 'maplimits', YLims_Change, 'style', 'map', 'headrad', 'rim')
    title(['Diff SD ', num2str(plotFreqs(Indx_F)), 'Hz'])
end
colormap('rdbu')


% identify edges
Filename = [Participants{Participant}, '_LAT_', Baseline, '_ICAd_Interped.set'];
EEG_BL = pop_loadset('filename', Filename, 'filepath', Paths.EEGdata);
highlightEpochs(EEG_BL, Window, BLevents)

Filename = [Participants{Participant}, '_LAT_', Session, '_ICAd_Interped.set'];
EEG_SD = pop_loadset('filename', Filename, 'filepath', Paths.EEGdata);
highlightEpochs(EEG_SD, Window, SDevents)

% make function to highlight eeg based on certain timepoints

% scroll through basline and SD

