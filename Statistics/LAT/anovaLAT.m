clear
clc
close all


Stats_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DataPath = fullfile(Paths.Analysis, 'Statistics', 'LAT', 'Data'); % for statistics

% Data type
% Type = 'Hits';
% YLabel = '%';
% Loggify = false; % msybe?
% 

% Type = 'Misses';
% YLabel = '%';
% Loggify = false; % msybe?

% Type = 'theta';
% YLabel = 'Power (log)';
% Loggify = true;
% 
% Type = 'meanRTs';
% YLabel = 'RTs (log(s))';
% Loggify = false;

Type = 'KSS';
YLabel = 'VAS Score';
Loggify = false;


MES = 'eta2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



load(fullfile(DataPath, ['LAT_', Type, '_Classic.mat']))
ClassicMatrix = Matrix;
if Loggify
    ClassicMatrix = log(ClassicMatrix);

end
        for Indx_P = 1:numel(Participants)
        ClassicMatrix(Indx_P, :) = mat2gray(ClassicMatrix(Indx_P, :));
    end

ClassicMeans = nanmean(ClassicMatrix);
ClassicSEM = nanstd(ClassicMatrix)./sqrt(size(ClassicMatrix, 1));
Classic = mat2table(ClassicMatrix, Participants, {'s1', 's2', 's3'}, 'Participant', [], Type);


load(fullfile(DataPath, ['LAT_', Type, '_Soporific.mat']))
SopoMatrix = Matrix;
if Loggify
    SopoMatrix = log(SopoMatrix);

end
    for Indx_P = 1:numel(Participants)
        SopoMatrix(Indx_P, :) = mat2gray(SopoMatrix(Indx_P, :));
    end

SopMeans = nanmean(SopoMatrix);
SopSEM = std(SopoMatrix)./sqrt(size(SopoMatrix, 1));

Soporific = mat2table(SopoMatrix, Participants, {'s4', 's5', 's6'}, 'Participant', [], Type);

Between = [Classic, Soporific(:, 2:end)];

Within = table();
Within.Session = {'B'; 'S1'; 'S2'; 'B'; 'S1'; 'S2'};
Within.Condition = {'C'; 'C'; 'C'; 'S'; 'S'; 'S'};

rm = fitrm(Between,'s1-s6~1', 'WithinDesign',Within);

ranovatbl = ranova(rm, 'WithinModel', 'Session*Condition');
SxC = multcompare(rm, 'Session', 'By', 'Condition');
CxS = multcompare(rm, 'Condition', 'By', 'Session');

%%% manually assemble p-values

% within session comparisons
BL_SvC = CxS.pValue(strcmp(CxS.Session, 'B')&strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
S1_SvC = CxS.pValue(strcmp(CxS.Session, 'S1')&strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
S2_SvC = CxS.pValue(strcmp(CxS.Session, 'S2')&strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));

% between session comparisons
S_BLvS1 = SxC.pValue(strcmp(SxC.Condition, 'S')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S1'));
S_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'S')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S2'));
S_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'S')&strcmp(SxC.Session_1, 'S1')& strcmp(SxC.Session_2, 'S2'));
C_BLvS1= SxC.pValue(strcmp(SxC.Condition, 'C')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S1'));
C_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'C')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S2'));
C_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'C')&strcmp(SxC.Session_1, 'S1')& strcmp(SxC.Session_2, 'S2'));

% plot barplots
figure('units','normalized','outerposition',[0 0 .4 .4])
subplot(1, 2, 1)
PlotBars([ClassicMeans; SopMeans]', [ClassicSEM; SopSEM]', {'BL', 'S1', 'S2'}, {'Classic', 'Soporific'})

title(['LAT ', Type])
ylabel(YLabel)

Colors = plasma(3); % TODO, make this only once, and not in plotbars

% plot significance 
% (if I'm ever inspired, I'll make this automated; for now its manual)
comparisons = {
[.9, 1.1], BL_SvC, [0 0 0];
[1.9, 2.1], S1_SvC, [0 0 0];
[2.9, 3.1], S2_SvC, [0 0 0];

[.9, 1.9], C_BLvS1, Colors(1, :);
[1.1, 2.1], S_BLvS1, Colors(2, :);
[.9, 2.9], C_BLvS2, Colors(1, :);
[1.1, 3.1], S_BLvS2,  Colors(2, :);
[1.9, 2.9], C_S1vS2, Colors(1, :);
[2.1, 3.1], S_S1vS2, Colors(2, :)};

comparisons([comparisons{:, 2}]>=0.1, :) = [];
if size(comparisons, 1) > 0
sigstar(comparisons(:, 1),[comparisons{:, 2}], comparisons(:, 3))
end


%%% plot effect sizes (with CIs?) of Session vs Condition


% uses the MES toolbox, so data needs to be restructured
ClassicTable = mat2table(ClassicMatrix, Participants, [1:size(ClassicMatrix, 2)]', ...
    'Participant', 'Session', 'Data');
ClassicTable.Condition = zeros(size(ClassicTable.Session));

SopoTable = mat2table(SopoMatrix, Participants, [1:size(SopoMatrix, 2)]', ...
    'Participant', 'Session', 'Data');
SopoTable.Condition = ones(size(SopoTable.Session));
Table = [ClassicTable; SopoTable];

stats = mes2way(Table.Data, [Table.Session, Table.Condition], MES, ...
    'fName',{'Session', 'Condition'}, 'isDep',[1 1], 'nBoot', 1000);
subplot(1, 2, 2)
hold on
bar(1:3, stats.(MES), 'FaceColor', [.5 .5 .5], 'LineStyle', 'none')
errorbar(1:3, stats.(MES), stats.(MES)-stats.([MES, 'Ci'])(:, 1),  stats.([MES, 'Ci'])(:, 2)-stats.(MES), ...
    'Color', 'k', 'LineStyle', 'none', 'LineWidth', 2 )
xticks(1:3)
xticklabels({'Session', 'Condition', 'Interaction'})
xlim([.5, 3.5])
ylim([0 1])
title(['Effect size: ', MES])
saveas(gcf,fullfile(Paths.Figures, 'ESRSPoster', [Type, '_Stats_LAT_timeXcondition.svg']))

% plot all values
% All =[ClassicMatrix(:); SopoMatrix(:)]; 
% YLims = [min(All), max(All)];
% figure('units','normalized','outerposition',[0 0 .4 .4])
% subplot(1,2,1)
% PlotConfettiSpaghetti(ClassicMatrix, {'BL', 'S1', 'S2'}, YLims, ['LAT Classic ', Type], [])
% 
% subplot(1,2,2)
% PlotConfettiSpaghetti(SopoMatrix, {'BL', 'S1', 'S2'}, [], ['LAT Soporific ', Type], [])
% saveas(gcf,fullfile(Paths.Figures, 'ESRSPoster', [Type, '_Means_LAT_timeXcondition.svg']))

% plot all values in same plot
figure('units','normalized','outerposition',[0 0 .4 .4])
PlotScales(ClassicMatrix, SopoMatrix, {'BL', 'S1', 'S2'}, {'Class', 'Sopo'})
ylabel(YLabel)
title(['LAT ', Type, ' All Means'])
 saveas(gcf,fullfile(Paths.Figures, 'ESRSPoster', [Type, '_LAT_timeANDcondition.svg']))

