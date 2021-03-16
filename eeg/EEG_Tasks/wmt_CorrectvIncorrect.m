SummaryFile = fullfile(Paths.Matrices, [Task '_', Normalization,'_Correct_WelchPower.mat']);
load(SummaryFile, 'Retention', 'Baseline', 'Encoding', 'Chanlocs')

Retention_C = Retention;
Baseline_C = Baseline;
Encoding_C = Encoding;


SummaryFile = fullfile(Paths.Matrices, [Task '_', Normalization,'_Incorrect_WelchPower.mat']);
load(SummaryFile, 'Retention', 'Baseline', 'Encoding')

Retention_I = Retention;
Baseline_I = Baseline;
Encoding_I = Encoding;


figure('units','normalized','outerposition',[0 0 1 1])
Indx=1;
for Indx_S = 1:numel(Sessions)
for Indx_L = 1:numel(Levels)+1
    
    if Indx_L <=numel(Levels)
    
    C = squeeze(nanmean(Retention_C(:, Indx_S, Indx_L, Indexes_Hotspot, :),4));
    I = squeeze(nanmean(Retention_I(:, Indx_S, Indx_L, Indexes_Hotspot, :),4));
    else
         C = squeeze(nanmean(nanmean(Baseline_C(:, Indx_S, :, Indexes_Hotspot, :),4),3));
    I = squeeze(nanmean(nanmean(Baseline_I(:, Indx_S, :, Indexes_Hotspot, :),4),3));
    end
    
    Matrix = cat(3, C, I);
    Matrix = permute(Matrix, [1, 3, 2]);
    
    subplot(numel(Sessions), numel(Levels)+1, Indx)
    PlotPowerHighlight(Matrix, Freqs, FreqsIndxBand, Colors, Format, {'Correct', 'Incorrect'})
    title([strjoin({'Retention', SessionLabels{Indx_S}, Legend{Indx_L}}, ' ')])
      if exist('YLim', 'var')
        ylim(YLim)
      end
    xlim([0 30])
    
    Indx = Indx+1;
end
end
NewLims = SetLims(numel(Sessions), numel(Levels)+1, 'y');