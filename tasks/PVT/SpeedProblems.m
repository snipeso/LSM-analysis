clear
clc
% close all

PVT_Parameters



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'PVT';
Condition = 'Comp';

% ColName = 'rt'; % or 'speed'
% YLim = [.1, 1];
% YLabel = 'RT (s)';

ColName = 'speed'; % or 'speed'
YLim = [-.1, 10];
YLabel = 'Speed (1/s)';


Shifts = [ -.1, -.05, -.025, 0, .025, .05, .1];
   Sessions = allSessions.([Task,Condition]);
SessionLabels = nan(1, numel(Shifts));

AllAnswers.speed = AllAnswers.rt;
figure( 'units','normalized','outerposition',[0 0 .7 .7])
hold on
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Shifts)
        
        Ans = cell2mat(AllAnswers.(ColName)(contains(AllAnswers.Session, 'BaselineComp') & ...
            strcmp(AllAnswers.Participant, Participants{Indx_P})))+Shifts(Indx_S);
        
        Ans(isnan(Ans)) = [];
        Ans(Ans < 0.1) = [];
        if size(Ans, 1) < 1
            continue
        end
        if strcmp(ColName, 'speed')
            Ans = 1./Ans;   
        end
        
        violin(Ans, 'x', [Indx_S, 0], 'facecolor', Format.Colors.DarkParticipants(Indx_P, :), ...
            'edgecolor', [], 'facealpha', 0.1, 'mc', [], 'medc', []);
        SessionLabels(Indx_S) = nanmean(Ans);
    end
end

xlim([0, numel(Shifts) + 1])
xticks(1:numel(Shifts))

xticklabels(round(1000*Shifts))

ylim(YLim)
ylabel(YLabel)
xlabel('Shift (ms)')

set(gca, 'FontName', Format.FontName, 'FontSize', 18)


figure
t = linspace(0.1, 1, 1000);
y = 1./t;
plot(t, y, 'LineWidth', 3, 'Color', Format.Colors.Generic.Dark1)
xlabel('RT')
ylabel('Speed')
axis square
set(gca, 'FontName', Format.FontName, 'FontSize', 15)


  BL = cell2mat(AllAnswers.rt(contains(AllAnswers.Session, 'BaselineComp')));
   SD = cell2mat(AllAnswers.rt(contains(AllAnswers.Session, 'Session2Beam')));
  figure
  subplot(2, 1, 1)
  histogram(BL-.05, 'BinEdges', 0.3:.01:1, 'EdgeColor', 'none', 'FaceColor', Format.Colors.Sessions(1, :))
  set(gca, 'FontName', Format.FontName, 'FontSize', 15)
title('Baseline')
hold on
  plot([.5 .5], [0, 10], 'LineWidth', 1.5, 'Color', [.6 .6 .6])
plot([.49 .49], [0, 10], 'LineWidth', 1.5, 'Color', [.4 .4 .4])
  ylim([0, 10])

  
    subplot(2, 1, 2)
  histogram(SD-.05, 'BinEdges', 0.3:.01:1, 'EdgeColor', 'none', 'FaceColor', Format.Colors.Sessions(2, :))
  set(gca, 'FontName', Format.FontName, 'FontSize', 15)
  title('Sleep Deprivation')
  hold on
  plot([.5 .5], [0, 10], 'LineWidth', 1.5, 'Color', [.6 .6 .6])
plot([.49 .49], [0, 10], 'LineWidth', 1.5, 'Color', [.4 .4 .4])
ylim([0, 10])
  xlabel('RT (s)')
  
  
 SD(SD<.1) = [];
 figure( 'units','normalized','outerposition',[0 0 .5 .5])
 histogram(SD, 'NumBins', 1000, 'EdgeColor', [0 0 0], 'FaceColor', [0 0 0])
  xlabel('RT (s)')
    set(gca, 'FontName', Format.FontName, 'FontSize', 15)
    box off
    set(gca,'ytick',[])