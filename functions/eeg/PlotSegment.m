function PlotSegment(EEG, Start, Stop, Channels)
% channels is a cell array of lists of channel numbers

Freqs = 1:0.5:30;
plotFreqs = [2:2:15, 20];
fs = EEG.srate;
Colormap = 'plasma';

 Data = EEG.data(:, round(Start*EEG.srate):round(Stop*EEG.srate));
    
[FFT, ~] = pwelch(Data', [], [], Freqs, fs);
Labels = cell(size(Channels));
    
figure
hold on
for Indx = 1:numel(Channels)
    plot(Freqs, 10*log(mean(FFT(:, Channels{Indx}), 2)))
    Labels{Indx} = num2str(Channels{Indx});
end
legend(Labels)

figure('units','normalized','outerposition',[0 0 1 .3])
FreqsIndx =  dsearchn( Freqs', plotFreqs');
for Indx = 1:numel(plotFreqs)
    subplot(1, numel(plotFreqs), Indx)
    topoplot(10*log(FFT(FreqsIndx(Indx), :)), EEG.chanlocs, 'style', 'map', 'headrad', 'rim');
    colorbar
    title([num2str(plotFreqs(Indx)), 'Hz'])
    
end

colormap(Colormap)