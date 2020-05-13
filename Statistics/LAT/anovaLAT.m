clear
clc
% close all


Stats_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DataPath = fullfile(Paths.Analysis, 'Statistics', 'LAT', 'Data'); % for statistics

% Data type

% Type = 'Hits';
% YLabel = '%';
% Loggify = false; % msybe?

Type = 'theta';
YLabel = 'Power (log)';
Loggify = true;
%
% Type = 'meanRTs';
% YLabel = 'RTs (log(s))';
% Loggify = false;
% 
% Type = 'KSS';
% YLabel = 'VAS Score';
% Loggify = false;


MES = 'eta2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



load(fullfile(DataPath, ['LAT_', Type, '_Classic.mat']))
ClassicMatrix = Matrix;
if Loggify
    ClassicMatrix = log(ClassicMatrix);
end

load(fullfile(DataPath, ['LAT_', Type, '_Soporific.mat']))
SopoMatrix = Matrix;

if Loggify
    SopoMatrix = log(SopoMatrix);
end


% z-score
for Indx_P = 1:numel(Participants)
    All = zscore([ClassicMatrix(Indx_P, :), SopoMatrix(Indx_P, :)]);
    ClassicMatrix(Indx_P, :) = All(1:size(ClassicMatrix, 2));
    SopoMatrix(Indx_P, :) = All(size(ClassicMatrix, 2)+1:end);
end

SopMeans = nanmean(SopoMatrix);
SopSEM = std(SopoMatrix)./sqrt(size(SopoMatrix, 1));
Soporific = mat2table(SopoMatrix, Participants, {'s4', 's5', 's6'}, 'Participant', [], Type);

ClassicMeans = nanmean(ClassicMatrix);
ClassicSEM = nanstd(ClassicMatrix)./sqrt(size(ClassicMatrix, 1));
Classic = mat2table(ClassicMatrix, Participants, {'s1', 's2', 's3'}, 'Participant', [], Type);


Between = [Classic, Soporific(:, 2:end)];

Within = table();

Within.Session= [0, 1, 2, 0, 1, 2]';
Within.Condition = {'C'; 'C'; 'C'; 'S'; 'S'; 'S'};

rm = fitrm(Between,'s1-s6~1', 'WithinDesign',Within);

% test of sphericity
% M = mauchly(rm);

ranovatbl = ranova(rm, 'WithinModel', 'Session*Condition');
SxC = multcompare(rm, 'Session', 'By', 'Condition');
CxS = multcompare(rm, 'Condition', 'By', 'Session');

%%% manually assemble p-values

% within session comparisons
BL_SvC = CxS.pValue(CxS.Session==0 & strcmp(CxS.Condition_1, 'S') & strcmp(CxS.Condition_2, 'C'));
S1_SvC = CxS.pValue(CxS.Session==1 & strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
S2_SvC = CxS.pValue(CxS.Session==2 &strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));

% between session comparisons
S_BLvS1 = SxC.pValue(strcmp(SxC.Condition, 'S')&SxC.Session_1==0& SxC.Session_2==1);
S_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'S')&SxC.Session_1==0& SxC.Session_2==2);
S_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'S')&SxC.Session_1==1& SxC.Session_2==2);
C_BLvS1= SxC.pValue(strcmp(SxC.Condition, 'C')&SxC.Session_1==0& SxC.Session_2==1);
C_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'C')&SxC.Session_1==0& SxC.Session_2==2);
C_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'C')&SxC.Session_1==1& SxC.Session_2==2);


% plot barplots
figure('units','normalized','outerposition',[0 0 .4 .4])
subplot(1, 3, 1)
PlotBars([ClassicMeans; SopMeans]', [ClassicSEM; SopSEM]', {'BL', 'S1', 'S2'})
legend({'Classic', 'Soporific'}, 'Location', 'southeast','AutoUpdate','off')
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

[stats, Table] = mes2way(Table.Data, [Table.Session, Table.Condition], MES, ...
    'fName',{'Session', 'Condition'}, 'isDep',[1 1], 'nBoot', 1000);
subplot(1, 3, 2)
hold on
bar(1:3, stats.(MES), 'FaceColor', [.5 .5 .5], 'LineStyle', 'none')
errorbar(1:3, stats.(MES), stats.(MES)-stats.([MES, 'Ci'])(:, 1),  stats.([MES, 'Ci'])(:, 2)-stats.(MES), ...
    'Color', 'k', 'LineStyle', 'none', 'LineWidth', 2 )
xticks(1:3)
xticklabels({'Session', 'Condition', 'Interaction'})
xlim([.5, 3.5])
ylim([0 1])
title(['ANOVA effect size: ', MES])

pValues = [cell2mat(Table( 3:5,6)), [1:3]'];
pValues(pValues(:, 1)>.1, :) = [];
for Indx = 1:size(pValues, 1)
    sigstar({[pValues(Indx, 2)-.1, pValues(Indx, 2)+.1]},[pValues(Indx, 1)], {[0 0 0]})
end


% pairwise effect sizes
Hedges = nan(2, 2);
HedgesCI = nan(2, 2, 2);
for Indx = 1:2
if Indx == 1
    Matrix = ClassicMatrix;
else
    Matrix = SopoMatrix;
end

stats = mes(Matrix(:, 2), Matrix(:, 1), 'hedgesg', 'isDep', 1, 'nBoot', 1000);
Hedges(1, Indx) = stats.hedgesg;
HedgesCI(1, Indx, :) = stats.hedgesgCi;

stats = mes(Matrix(:, 3), Matrix(:, 2), 'hedgesg', 'isDep', 1, 'nBoot', 1000);
Hedges(2, Indx) = stats.hedgesg;
HedgesCI(2, Indx, :) = stats.hedgesgCi;


end
subplot(1, 3, 3)
PlotBars(Hedges, HedgesCI, {'BLvsS1','S1vsS2'})
title(['Hedges g'])
ylim([-3 7])


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



% TODO:
% - compare effect sizes
% TODO: use ordered dummy contrasts!!! I think ANOVA picks up on it, since
% now it;s not significant anymore


