close all

BL_mu = .25;
BL_sigma = .05;
BL_skew = 2.5;
BL_kurt = 20;

SD_mu = .3;
SD_sigma = .1;
SD_skew = 3;
SD_kurt = 25;



m = 100000;
n = 1;

SD_Color = [0.9216 0.3725 0.4157];
BL_Color = [0.0941 0.1608 0.6510];

Shift_Colors = [    0.8941    0.4078    0.3529;
    0.9569    0.5765    0.3333;
    0.9608    0.7333    0.1922;
    0.8980    0.8157    0.1490;
    0.7529    0.8078    0.1529;
    0.4353    0.7647    0.2627;
    0.1294    0.6549    0.5373;
    0.1686    0.4745    0.7608;
    0.3490    0.3490    0.8902;
    0.5373    0.3412    0.8745;
    0.7373    0.3373    0.8784;
    0.8745    0.4824    0.7216];

% histogram


BL = pearsrnd(BL_mu,BL_sigma,BL_skew,BL_kurt,m,n);
SD = pearsrnd(SD_mu,SD_sigma,SD_skew,SD_kurt,m,n);
% figure('units','normalized','outerposition',[0 0 1 1])
% subplot(2, 2, 1)
% histogram(BL, 'BinEdges', 0:.02:1, 'EdgeColor', 'none', 'FaceColor', BL_Color, 'FaceAlpha', .5)
% hold on
% histogram(SD, 'BinEdges', 0:.02:1, 'EdgeColor', 'none', 'FaceColor', SD_Color, 'FaceAlpha', .5)
% xlim([.1 1])
% yticks([])
% xlabel('RT (s)')
% title('Reaction Times')
% set(gca, 'FontSize', 12, 'FontName', 'Arial Nova')
% box off
% axis square
% legend({'Baseline', 'Sleep Deprivation'})
% 
% subplot(2,2, 2)
% histogram(1./BL, 'BinEdges', 0:.1:6, 'EdgeColor', 'none', 'FaceColor', BL_Color, 'FaceAlpha', .5)
% hold on
% histogram(1./SD, 'BinEdges', 0:.1:6, 'EdgeColor', 'none', 'FaceColor', SD_Color, 'FaceAlpha', .5)
% 
% yticks([])
% xlabel('Speed (1/s)')
% title('Speed')
% set(gca, 'FontSize', 12, 'FontName', 'Arial Nova')
% box off
% axis square
% 
% 
% subplot(2,2, 3)
% histogram(SD-BL, 'BinEdges', -1:.03:1, 'EdgeColor', 'none', 'FaceColor', [0 0 0], 'FaceAlpha', .5)
% yticks([])
% xlabel('RT difference (s)')
% title('SD - BL')
% set(gca, 'FontSize', 12, 'FontName', 'Arial Nova')
% box off
% axis square
% 
% 
% subplot(2,2, 4)
% histogram((1./SD)-(1./BL), 'BinEdges', -3:.1:3, 'EdgeColor', 'none', 'FaceColor', [0 0 0], 'FaceAlpha', .5)
% yticks([])
% xlabel('RT difference (s)')
% title('SD - BL')
% set(gca, 'FontSize', 12, 'FontName', 'Arial Nova')
% box off
% axis square



%%

% Shifting means results in very different speeds
% Shifts = -.075:.025:.1;
% Shifts = [0, .025, .2, .225];

Shifts = [0, .03, .2, .23];

Shift_Colors = [   213, 104, 101;
    234, 177, 176;
    116, 122, 206;
    175, 179, 227
    ]/255;

%%

figure('units','normalized','outerposition',[0 0 .5 .6])
hold on
x = linspace(.1, 1, 1000);
y = 1./x;
ylim([0, 10])
xlim([.1 .7])
xticks(.1:.1:.7)
ylim([1 5])
plot(x, y, 'LineWidth', 2.5, 'Color', [0 0 0])
hold on

for Indx_S = 1:numel(Shifts)
    x =  BL_mu+Shifts(Indx_S);
    y=  1/x;
    plot([0, x], [y, y], ':', 'Color', [.75 .75 .75], 'Linewidth',1 )
    plot([x, x], [0, y], ':', 'Color', [.75 .75 .75],'Linewidth',1 )
end
scatter(BL_mu+Shifts, 1./(BL_mu+Shifts), 100, Shift_Colors,  'filled')
xlabel('RT(s)')
ylabel('Speed (1/s)')
axis square
set(gca, 'FontSize', 15, 'FontName', 'Arial Nova')
title('1/RT', 'FontSize', 18)


figure('units','normalized','outerposition',[0 0 .4 .6])
for Indx_S = 1:numel(Shifts)
    subplot(2,1, 1)
    hold on
    histogram(BL+Shifts(Indx_S), 'BinEdges', 0.05:.005:.8, 'EdgeColor', 'none', 'FaceColor', Shift_Colors(Indx_S, :), 'FaceAlpha', .75)
    yticks([])
    xlabel('RT (s)')
   
    set(gca, 'FontSize', 12, 'FontName', 'Arial Nova')
     title('Reaction times, shifted by 30ms', 'FontSize', 18)
    box off
    Mean = mean(BL+Shifts(Indx_S));
    plot([Mean, Mean], [0, 7000], 'Color', Shift_Colors(Indx_S, :), 'LineWidth', 2.5)
    ylim( [0, 7000])
    xlim([.15, .7])
    ylabel('# RTs')
    subplot(2,1, 2)
    hold on
    histogram(1./(BL+Shifts(Indx_S)), 'BinEdges', 0:.05:6, 'EdgeColor', 'none', 'FaceColor', Shift_Colors(Indx_S, :), 'FaceAlpha', .75)
    
    Mean = mean(1./(BL+Shifts(Indx_S)));
    plot([Mean, Mean], [0, 13000], 'Color', Shift_Colors(Indx_S, :), 'LineWidth', 2.5)
    yticks([])
    ylim([0, 13000])
     ylabel('# RTs')
    xlim([1.3, 5.5])
    xlabel('1/RT (s^-^1)')
  
    set(gca, 'FontSize', 12, 'FontName', 'Arial Nova')
      title('Speeds', 'FontSize', 18)
    box off
    
    
end

%%

% effect sizes
% Cohen's d = (M1 - M2)/sqrt((S1^2 + S2^2)/2)
Means = .1:.05:.7;
Shift = .03;
D_RT = nan(size(Means));
D_Speed =  nan(size(Means));


for Indx_M = 1:numel(Means)
    BL_temp = BL - (BL_mu-Means(Indx_M));
    SD_temp = BL_temp + Shift;
    D_RT(Indx_M) = CohenD(BL_temp*1000, SD_temp*1000);
    
        D_Speed(Indx_M) = CohenD(1./(BL_temp), 1./(SD_temp));
% figure
% subplot(1, 2, 1)
% histogram(BL_temp, 'BinEdges', 0.05:.005:.8);hold on;histogram( SD_temp, 'BinEdges', 0.05:.005:.8)
% subplot(1, 2, 2)
% histogram(1./BL_temp);hold on;histogram(1./SD_temp)
%     
end

figure('units','normalized','outerposition',[0 0 .5 .5])
subplot(1, 2, 1)
bar(Means, D_RT)
xlabel('BL Mean')
ylabel('Cohens D')
title('RT effect sizes')
% ylim([.5 .9])
subplot(1, 2, 2)
bar(Means, D_Speed)
xlabel('BL Mean')
ylabel('Cohens D')
title('Speed effect sizes')
% ylim([.5 .9])
% 
% %%
% 
% % plot RT vs Speeds, and slowest/fastest 10%
% 
% 
% figure('units','normalized','outerposition',[0 0 1 .5])
% 
% subplot(1, 3, 1)
% hold on
% x = linspace(.1, 1, 1000);
% y = 1./x;
% plot(x, y, 'LineWidth', 2, 'Color', BL_Color)
% xlabel('RT(s)')
% ylabel('Speed')
% % title('Reciprocal Transform from Delays to Speed')
% axis square
% set(gca, 'FontSize', 12, 'FontName', 'Arial Nova')
% 
% 
% subplot(1, 3, 1)
% hold on
% x = linspace(.1, 1, 1000);
% y = 1./x;
% plot(x, y, 'LineWidth', 2, 'Color', BL_Color)
% xlabel('RT(s)')
% ylabel('Speed')
% axis square
% set(gca, 'FontSize', 12, 'FontName', 'Arial Nova')

