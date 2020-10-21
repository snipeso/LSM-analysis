clear
clc
close all

run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))

Window = 30;
Overlap = .33;
Taper = false;
CAxis = [0 1];

Path = 'C:\Users\colas\Desktop\Temp\P09_Sleep_Baseline';

Content = string(ls(Path));
Content(~contains(Content, '.vis')) = [];
Filename = deblank(Content(1));

visfilename = fullfile(Path, Filename);
[vistrack, vissymb, offs] = visfun.readtrac(visfilename, 1);

[visnum] = visfun.numvis(vissymb, offs);
% [visplot] = visfun.plotvis(visnum, 10);

Legend = {
    1, 'w';
    0, 'r';
    -1, 'n1';
    -2, 'n2';
    -3, 'n3'
    };


Filename = 'P09_Sleep_Baseline_Scoring.set';
Filepath = 'C:\Users\colas\Desktop\Temp';
EEG = pop_loadset('filename', Filename, 'filepath', Filepath);

Mastoids = [57 100];
EEG = pop_reref(EEG, Mastoids);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% correlation across channels

% Format.Colormap.Linear = inferno;
Chanlocs = EEG.chanlocs;

DAllCh = [];
for Indx_Ch = 1:numel(Chanlocs)
    [R, Windows] = SnipletCorrelation(EEG.data(Indx_Ch, :), Window*EEG.srate, Overlap, Taper);
    DAllCh = cat(1, DAllCh, squareform(1-R));
end

%%
FFTPoints = size(R, 2);

% plot the logic: correlation of some channels
figure('units','normalized','outerposition',[0 0 .5 .8])
ChLabel = [24, 124, 70, 83];
Ch = find(ismember({Chanlocs.labels}, string(ChLabel)));
for Indx_Ch = 1:numel(Ch)
    subplot(2, 2, Indx_Ch)
    [R, Windows] = SnipletCorrelation(EEG.data(Ch(Indx_Ch), :), Window*EEG.srate, Overlap, Taper);
    imagesc(R)
    colorbar
    colormap(Format.Colormap.Linear)
    caxis(CAxis)
    axis square
    title(num2str(ChLabel(Indx_Ch)))
end

figure('units','normalized','outerposition',[0 0 1 1])
subplot(6, 1, 1:5)
imagesc(R)
colorbar
colormap(Format.Colormap.Divergent)
% caxis(CAxis)
caxis([-1 1])
axis off

subplot(6, 1, 6)
PlotHypnogram(visnum, Format)
colorbar
set(colorbar,'visible','off')

%%
% figure('units','normalized','outerposition',[0 0 .5 .8])
% imagesc(-(DAllCh-1))
% colorbar
% colormap(Format.Colormap.Linear)
% caxis([.2, 1])

% whole recording
R = corrcoef(DAllCh');

figure('units','normalized','outerposition',[0 0 .6 .8])
subplot(2, 2, 1)
PlotTopoNodes(abs(R), [.7 1.5], Chanlocs, Format)
title('Whole Sleep FFT Correlations')
set(findall(gca, 'type', 'text'), 'visible', 'on',...
    'FontName', Format.FontName, 'FontSize', 12)
subplot(2, 2, 3)
PlotTopoNodes(abs(R), [.7 1.5], Chanlocs, Format)
set(gca, 'view', [0 0])

Rraw = corrcoef(EEG.data');
subplot(2, 2, 2)
PlotTopoNodes(Rraw, [.7 1.5], Chanlocs, Format)
title('Whole Sleep Raw Correlations')
set(findall(gca, 'type', 'text'), 'visible', 'on',...
    'FontName', Format.FontName, 'FontSize', 12)
subplot(2, 2, 4)
PlotTopoNodes(Rraw, [.7 1.5], Chanlocs, Format)
set(gca, 'view', [0 0])

% set(gca, 'view', [0 0])
% set(gca, 'view', [0 90])


% by sleep stage

% get stages per window
FFTStagePoints = round(linspace(1, numel(visnum), FFTPoints)); % associate point of stages for every r value

FFTStages = nan(1, FFTPoints);
for Indx_P = 1:FFTPoints
    FFTStages(Indx_P) = visnum(FFTStagePoints(Indx_P));
end
DStages = repmat(FFTStages', 1, FFTPoints)';
DStages(tril(true(FFTPoints, FFTPoints))) = nan; % set to nan lower triangle and diagonal
DStages = DStages';
DStages = DStages(:);
DStages(isnan(DStages)) = [];
DStages = DStages';


nStages = size(Legend, 1);
figure('units','normalized','outerposition',[0 0 1 .55])
for Indx_S = 1:nStages
    subplot(2, nStages, Indx_S)
    Stage = Legend{Indx_S, 1}==DStages;
    R = corrcoef(DAllCh(:, Stage)');
    PlotTopoNodes(R, [.7 1.5], Chanlocs, Format)
    title([Legend{Indx_S, 2}])
    set(findall(gca, 'type', 'text'), 'visible', 'on',...
        'FontName', Format.FontName, 'FontSize', 12)
    subplot(2, nStages, Indx_S+nStages)
    PlotTopoNodes(R, [.7 1.5], Chanlocs, Format)
    set(gca, 'view', [0 0])
end

% raw

% get stages per window
RawPoints = size(EEG.data, 2);
RawStagePoints = round(linspace(1, numel(visnum), RawPoints)); % associate point of stages for every r value
RawStages = nan(1, RawPoints);
for Indx_P = 1:RawPoints
    RawStages(Indx_P) = visnum(RawStagePoints(Indx_P));
end


figure('units','normalized','outerposition',[0 0 1 .55])
for Indx_S = 1:nStages
    subplot(2, nStages, Indx_S)
    Stage = Legend{Indx_S, 1}==RawStages;
    R = corrcoef(EEG.data(:, Stage)');
    PlotTopoNodes(R, [.7 1.5], Chanlocs, Format)
    title([Legend{Indx_S, 2}, ' raw'])
    set(findall(gca, 'type', 'text'), 'visible', 'on',...
        'FontName', Format.FontName, 'FontSize', 12)
    subplot(2, nStages, Indx_S+nStages)
    PlotTopoNodes(R, [.7 1.5], Chanlocs, Format)
    set(gca, 'view', [0 0])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% correlation across stages


% plot cor, sorted by sleep stages

% get stages per window
RStagePoints = round(linspace(1, numel(visnum), FFTPoints)); % associate point of stages for every r value
FFTRStages = nan(1, FFTPoints);
for Indx_P = 1:FFTPoints
    FFTRStages(Indx_P) = visnum(RStagePoints(Indx_P));
end


figure('units','normalized','outerposition',[0 0 .5 .8])
[~, Order] = sort(FFTRStages);
for Indx_Ch = 1:numel(Ch)
    switches = find(diff(FFTRStages(Order))>0);
    
    subplot(2, 2, Indx_Ch)
    [R, Windows] = SnipletCorrelation(EEG.data(Ch(Indx_Ch), :), Window*EEG.srate, Overlap, Taper);
    
    R = R(Order, :);
    for sw = switches
        R(sw:sw+2, :) = 1;
    end
    imagesc(R)
    colorbar
    colormap(Format.Colormap.Linear)
    caxis(CAxis)
    axis square
    title(num2str(ChLabel(Indx_Ch)))
    
    yticks(switches)
    yticklabels(flip(Legend(:, 2)))
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% feature selection

% select snippet
% pop_eegplot(EEG)

Overlap_Small = .5;


Snippet_T = [17706 17710, 25]; % blinks
PlotFeatureSelection(EEG, visnum, Snippet_T, 'Blink', Overlap_Small, CAxis, Format)
%
Snippet_T = [150 154, 84]; % alpha
PlotFeatureSelection(EEG, visnum, Snippet_T, 'alpha', Overlap_Small, CAxis, Format)

Snippet_T = [1822 1826, 3]; % k-complex
PlotFeatureSelection(EEG, visnum, Snippet_T, 'K-Complex', Overlap_Small, CAxis, Format)

Snippet_T = [19718 19723.5, 30]; % spindle
PlotFeatureSelection(EEG, visnum, Snippet_T, 'Spindle', Overlap_Small, CAxis, Format)

Snippet_T = [3535 3550, 10]; % SWA
PlotFeatureSelection(EEG, visnum, Snippet_T, 'SWA', Overlap_Small, CAxis, Format)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% correlate contemporary sniplets across channels

% run corr
SnipletsCorr = GlobalSnipletCorrelation(EEG.data, Window*EEG.srate, Overlap, Taper);

% plot 4ch raw
ChLabel = [24, 124, 70, 83];
Ch = find(ismember({Chanlocs.labels}, string(ChLabel)));

% t = linspace(0, EEG.pnts/EEG.srate, size(SnipetsCorr, 3));
% SnipletsCorrZ = zscore(SnipletsCorr);

% plot 4 ch z-scored
figure('units','normalized','outerposition',[0 0 1 1])
for Indx_Ch = 1:numel(Ch)
    Data = squeeze(SnipletsCorr(Ch(Indx_Ch), :, :));
    %     Data = zscore((1-abs(Data))')';
    % Data = 1-abs(Data);
    subplot(numel(Ch)+1, 1, Indx_Ch)
    imagesc(Data)
    colorbar
    colormap(inferno)
    title([num2str(ChLabel(Indx_Ch)), ' Correlations'])
    caxis([0 1])
    caxis([.9 1])
end

subplot(numel(Ch)+1, 1, Indx_Ch+1)
PlotHypnogram(visnum, Format)
colorbar
set(colorbar,'visible','off')


% plot average connections per sleep stage

SnipletPoints = size(SnipletsCorr, 3);

% get stages per window
SnipletStagePoints = round(linspace(1, numel(visnum), SnipletPoints)); % associate point of stages for every r value

SnipletStages = nan(1, SnipletPoints);
for Indx_P = 1:SnipletPoints
    SnipletStages(Indx_P) = visnum(SnipletStagePoints(Indx_P));
end


nStages = size(Legend, 1);
figure('units','normalized','outerposition',[0 0 1 .55])
for Indx_S = 1:nStages
    subplot(2, nStages, Indx_S)
    Stage = Legend{Indx_S, 1}==SnipletStages;
    R = squeeze(mean(SnipletsCorr(:, :, Stage), 3));
    PlotTopoNodes(R, [.5 1], Chanlocs, Format)
    title([Legend{Indx_S, 2}])
    set(findall(gca, 'type', 'text'), 'visible', 'on',...
        'FontName', Format.FontName, 'FontSize', 12)
    subplot(2, nStages, Indx_S+nStages)
    PlotTopoNodes(R, [.5 1], Chanlocs, Format)
    set(gca, 'view', [0 0])
end





% per sleep stage, for specific ch, identify drops in "global corr" (so not
% neighboring ch), plot overlayed with global average corr (might be able
% to ignore drops in corr if they happen all together)


%% sort windows by corr

Ch = 122;
[R, Windows] = SnipletCorrelation(EEG.data(Ch, :), 10*EEG.srate, 0.5, true);

clusters = cluster_corr(R, 0);
[Cat, Order] = sort(clusters);
figure;
imagesc(R(Order, :)); colorbar;colormap(rdbu);caxis([-1 1])
switches = find(diff(Cat)>0);
yticks(switches)
yticklabels(unique(Cat))



% plot spectrums of all snippets in butterfly plot
Cat = unique(Cat);

Freqs = 2:.5:35;


for Indx_C = 1:numel(Cat)
    
    subWindows = Windows(clusters==Cat(Indx_C), :);
    if size(subWindows, 1) < 20
        continue
    end
    
  figure('units','normalized','outerposition',[0 0 .25 .5])
     title(num2str(Cat(Indx_C)))
    hold on
    FFT = nan(size(subWindows, 1), numel(Freqs));
    for Indx_W = 1:size(subWindows, 1)
        [pxx, f] = pwelch(EEG.data(Ch, subWindows(Indx_W, 1):subWindows(Indx_W, 2)), [], 0, Freqs, EEG.srate);
        plot(Freqs, log(pxx), 'Color', [.5 .5 .5 .2])
        FFT(Indx_W, :) = log(pxx);
    end
    plot(Freqs, nanmean(FFT, 1), 'Color', Format.Colors.Generic.Red, 'LineWidth', 2)
    xlim([Freqs(1), Freqs(end)])
    ylim([-6 6])
end