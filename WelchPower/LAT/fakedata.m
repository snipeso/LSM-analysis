
clc
close all
% BL = [1000 500 250 125 60 30 15 7 3];
% SD = [1000 500 250 125 60 60 30 8.4 3];
% 
BL = [1000 500 250 125 60 30 15 7 3];
SD = [2000 1000 300 125 60 30 15 7 3];
Freqs = linspace(.5, 4, numel(SD));
figure( 'units','normalized','outerposition',[0 0 .5 .5])
subplot(1, 2, 1)
hold on
plot(Freqs, BL, 'LineWidth', 2, 'Color', [0 1 0])
plot(Freqs, SD, 'LineWidth', 2, 'Color', [1 0 1])
plot(Freqs, mean(BL)*ones(1, numel(SD)), ':', 'Color', [0 1 0], 'LineWidth', 2)
plot(Freqs, mean(SD)*ones(1, numel(SD)), ':', 'Color', [1 0 1], 'LineWidth', 2)
xlabel('Frequencies')
ylabel('raw power')
legend({'Fake Sham','Fake Up Stim', 'delta sham', 'delta up stim'})
title('Power')
xlim([min(Freqs), max(Freqs)])


subplot(1,2,2)
hold on
Change = 100*(SD-BL)./BL;
plot(Freqs, Change, 'LineWidth', 2, 'Color', 'b')
plot(Freqs, mean(Change)*ones(1, numel(SD)), ':', 'Color','b', 'LineWidth', 2)

mSD = mean(SD);
mBL = mean(BL);
ChangeMean = 100*(mSD-mBL)./mBL;
plot(Freqs,  mean(ChangeMean)*ones(1, numel(SD)), 'Color', 'r', 'LineWidth', 2)


xlim([min(Freqs), max(Freqs)])
ylabel('% change')
legend({'Change by freq', 'mean change by freq', 'mean change of delta'})
title('Difference between Up and Down')


xlabel('Frequencies')

