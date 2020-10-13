
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))

Window = 30;
Overlap = .33;
Taper = true;

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

Format.Colormap.Linear = inferno;
Chanlocs = EEG.chanlocs;

DAllCh = [];
for Indx_Ch = 1:numel(Chanlocs)
    [R, Windows] = SnipletCorrelation(EEG.data(Indx_Ch, :), Window*EEG.srate, Overlap, Taper);
    DAllCh = cat(1, DAllCh, squareform(1-R));
end

FFTPoints = size(R, 2);

% plot the logic: correlation of some channels
figure('units','normalized','outerposition',[0 0 .5 .8])
ChLabel = [24, 124, 70, 83];
Ch = find(ismember({Chanlocs.labels}, string(Ch)));
for Indx_Ch = 1:numel(Ch)
    subplot(2, 2, Indx_Ch)
    [R, Windows] = SnipletCorrelation(EEG.data(Indx_Ch, :), Window*EEG.srate, Overlap, Taper);
    imagesc(R)
    colorbar
    colormap(Format.Colormap.Linear)
    caxis([.6, 1])
    axis square
    title(num2str(ChLabel(Indx_Ch)))
end

figure('units','normalized','outerposition',[0 0 .5 .8])
imagesc(-(DAllCh-1))
colorbar
colormap(Format.Colormap.Linear)
caxis([.2, 1])

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
    [R, Windows] = SnipletCorrelation(EEG.data(Indx_Ch, :), Window*EEG.srate, Overlap, Taper);
    
    R = R(Order, :);
    for sw = switches
        R(sw:sw+2, :) = 1;
    end
    imagesc(R)
    colorbar
    colormap(Format.Colormap.Linear)
    caxis([.6, 1])
    axis square
    title(num2str(ChLabel(Indx_Ch)))
    
    yticks(switches)
    yticklabels(flip(Legend(:, 2)))
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assmeble "average per stage", run on 2 channels, and see when there's
% most disagreement?





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% maxclustering












