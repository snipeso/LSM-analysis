
clc
close all
BL = [1000 500 250 125 60 30 15 7 3];
SD = [1000 500 250 125 60 60 30 20 3];
Freqs = linspace(.5, 4, numel(SD));
figure( 'units','normalized','outerposition',[0 0 .8 .5])
subplot(1, 3, 1)
hold on
plot(Freqs, BL, 'LineWidth', 2, 'Color', [0 1 0])
plot(Freqs, SD, 'LineWidth', 2, 'Color', [1 0 1])
plot(Freqs, mean(BL)*ones(1, numel(SD)), ':', 'Color', [0 1 0], 'LineWidth', 2)
plot(Freqs, mean(SD)*ones(1, numel(SD)), ':', 'Color', [1 0 1], 'LineWidth', 2)
xlabel('Frequencies')
ylabel('raw power')
legend({'Fake Down Stim','Fake Up Stim'})
title('Power')
xlim([min(Freqs), max(Freqs)])

subplot(1, 3, 2)
hold on
plot(Freqs, log(BL), 'LineWidth', 2, 'Color', [0 1 0])
plot(Freqs, log(SD), 'LineWidth', 2, 'Color', [1 0 1])
plot(Freqs, mean(log(BL))*ones(1, numel(SD)), ':', 'Color', [0 1 0], 'LineWidth', 2)
plot(Freqs, mean(log(SD))*ones(1, numel(SD)), ':', 'Color', [1 0 1], 'LineWidth', 2)
xlabel('Frequencies')
ylabel('log power')
legend({'Fake Down Stim','Fake Up Stim'})
title('Log power')
xlim([min(Freqs), max(Freqs)])
subplot(1,3,3)
hold on
Change = 100*(SD-BL)./BL;
plot(Freqs, Change, 'LineWidth', 2, 'Color', 'b')
plot(Freqs, mean(Change)*ones(1, numel(SD)), ':', 'Color','b', 'LineWidth', 2)

mSD = mean(SD);
mBL = mean(BL);
ChangeMean = 100*(mSD-mBL)./mBL;
plot(Freqs,  mean(ChangeMean)*ones(1, numel(SD)), 'Color', 'r', 'LineWidth', 2)

mSD = mean(log(SD));
mBL = mean(log(BL));
ChangeMean = 100*(mSD-mBL)./mBL;
plot(Freqs,  mean(ChangeMean)*ones(1, numel(SD)), 'Color', 'g', 'LineWidth', 2)
xlim([min(Freqs), max(Freqs)])
ylabel('% change')
legend({'Change by freq', 'mean change by freq', 'mean change of delta', 'mean change of log of delta'})
title('Difference between Up and Down')


xlabel('Frequencies')

