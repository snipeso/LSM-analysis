clear
clc
close all
wpLAT_Parameters

BLData = allFFT(1).FFT;
SDData = allFFT(9).FFT;

rows = 2;
plots = 4;
Channel = 11;

FreqsTheta =  dsearchn(Freqs', [4, 8]');
FreqsCustomTheta =  dsearchn(Freqs', [3, 6]');


A = [squeeze(nanmean(BLData(Channel, :, :), 3)); squeeze(nanmean(SDData(Channel, :, :), 3))];
tempChange(A, Freqs, 'raw power')

figure( 'units','normalized','outerposition',[0 0 1 .5])
subplot(rows, plots, 1)
tempPlot(A, Freqs)
title('Raw power')

subplot(rows, plots, 2)
A = [log(squeeze(nanmean(BLData(Channel, :, :), 3))); log(squeeze(nanmean(SDData(Channel, :, :), 3)))];
tempChange(A, Freqs, 'log of average')

tempPlot(A, Freqs)
title('log of average')


A = [squeeze(nanmean(log(BLData(Channel, :, :)), 3)); squeeze(nanmean(log(SDData(Channel, :, :)), 3))];
tempChange(A, Freqs, 'average of logs')

subplot(rows, plots, 3)
tempPlot(A, Freqs)
title('Average of logs')


subplot(rows, plots, 4)
A = [squeeze(nanmean(log(BLData(Channel, :, :) + 1), 3)); squeeze(nanmean(log(SDData(Channel, :, :) + 1), 3))];
tempChange(A, Freqs, 'average of log+1')


tempPlot(A, Freqs)
title('Average of log(x+1)')


subplot(rows, plots, plots+1)
A = -[squeeze(nanmean(BLData(Channel, :, :), 3))-squeeze(nanmean(SDData(Channel, :, :), 3))];
tempPlot(A, Freqs)
title('Raw power diff')

subplot(rows, plots, plots+2)
A = -[log(squeeze(nanmean(BLData(Channel, :, :), 3)))-log(squeeze(nanmean(SDData(Channel, :, :), 3)))];
tempPlot(A, Freqs)
title('log of average diff')

subplot(rows, plots, plots+3)
A = -[squeeze(nanmean(log(BLData(Channel, :, :)), 3))-squeeze(nanmean(log(SDData(Channel, :, :)), 3))];
tempPlot(A, Freqs)
title('Average of logs diff')

subplot(rows, plots, plots+4)
A = -[squeeze(nanmean(log(BLData(Channel, :, :) + 1), 3))-squeeze(nanmean(log(SDData(Channel, :, :) + 1), 3))];
tempPlot(A, Freqs)
title('Average of log(x+1) diff')



figure( 'units','normalized','outerposition',[0 0 1 .5])
plots = 2;
subplot(1, plots, 1)
BL = nanmean(BLData(Channel, :, :), 3);
SD = nanmean(SDData(Channel, :, :),3);
A = 100*(SD-BL)./BL;
tempPlot(A, Freqs)
ylabel('% change')
title('% Change (from average)')

subplot(1, plots, 2)
BL = nanmean(BLData(Channel, :, :), 3);
SD = squeeze(SDData(Channel, :, :));
A = nanmean(100*(SD-BL')./BL', 2)';
tempPlot(A, Freqs)
ylabel('% change')
title('average % change')

