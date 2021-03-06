clear
clc
% close all


Stats_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Task1 = 'LAT';
FigureFolder = 'NeuroMeets';

DataPath = fullfile(Paths.Analysis, 'statistics', 'Data'); % for statistics

Task = 'NotMicrosleeps';
% Colors.Tasks.(Task) = Colors.Tasks.(Task1);
Colors.Tasks.(Task) = Colors.Generic.Red;

% Data type

% Type = 'Misses';
% YLabel = '%';
% Loggify = false; % msybe?

Type = 'Theta';
YLabel = 'Power (log)';
Loggify = true;
ZScore = true;

% Type = 'meanRTs';
% YLabel = 'RTs (log(s))';
% Loggify = false;

% Type = 'KSS';
% YLabel = 'VAS Score';
% Loggify = false;

%
% Type = 'miDuration'; % miDuration, % miStart miTot
% YLabel = 'Seconds';
% Loggify = false;



MES = 'eta2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Figure_Path = fullfile(Paths.Figures, FigureFolder);
if ~exist(fullfile(Figure_Path), 'dir')
    mkdir(Figure_Path)
end

ClassicMatrix = [];
SopoMatrix = [];

Task1 = {'LAT', 'PVT'};
for Indx_T = 1:2
    load(fullfile(DataPath, Task1{Indx_T}, [Task, '_', Type, '_Classic.mat']))
    ClassicMatrix = cat(2, ClassicMatrix, Matrix);
    
    load(fullfile(DataPath, Task1{Indx_T}, [Task, '_', Type, '_Soporific.mat']))
    SopoMatrix = cat(2, SopoMatrix, Matrix);
end

if Loggify
    ClassicMatrix = log(ClassicMatrix);
end


if Loggify
    SopoMatrix = log(SopoMatrix);
end


% z-score
if ZScore
    for Indx_P = 1:numel(Participants)
        All = zscore([ClassicMatrix(Indx_P, :), SopoMatrix(Indx_P, :)]);
        ClassicMatrix(Indx_P, :) = All(1:size(ClassicMatrix, 2));
        SopoMatrix(Indx_P, :) = All(size(ClassicMatrix, 2)+1:end);
    end
end

% levene test on variance (maybe should be done after?)
% Groups = repmat([1 2 3], numel(Participants), 1);
% Levenetest([ClassicMatrix(:), Groups(:); SopoMatrix(:), 3+Groups(:),6+Groups(:),9+Groups(:) ],.05)
% pause(1)

SM2 = [SopoMatrix(:, 1:3); SopoMatrix(:, 4:6)];
SopMeans = nanmean(SM2);
SopSEM = std(SM2)./sqrt(size(SM2, 1));
Soporific = mat2table(SopoMatrix, Participants, {'s7', 's8', 's9', 's10', 's11', 's12'}, 'Participant', [], Type);

CM2 = [ClassicMatrix(:, 1:3); ClassicMatrix(:, 4:6)];
ClassicMeans = nanmean(CM2);
ClassicSEM = nanstd(CM2)./sqrt(size(CM2, 1));
Classic = mat2table(ClassicMatrix, Participants, {'s1', 's2', 's3','s4', 's5', 's6'}, 'Participant', [], Type);


Between = [Classic, Soporific(:, 2:end)];

Within = table();

% Within.Session= [0, 1, 2, 0, 1, 2]';
Within.Session = {'B'; 'S1'; 'S2'; 'B'; 'S1'; 'S2'; 'B'; 'S1'; 'S2'; 'B'; 'S1'; 'S2'};
Within.Condition = {'C'; 'C'; 'C'; 'C'; 'C'; 'C'; 'S'; 'S'; 'S';'S'; 'S'; 'S'};

rm = fitrm(Between,'s1-s12~1', 'WithinDesign',Within);

% test of sphericity
% M = mauchly(rm);

[ranovatbl, ~, c] = ranova(rm, 'WithinModel', 'Session*Condition');
SxC = multcompare(rm, 'Session', 'By', 'Condition');
CxS = multcompare(rm, 'Condition', 'By', 'Session');

%%% manually assemble p-values

BL_SvC = CxS.pValue(strcmp(CxS.Session, 'B')&strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
S1_SvC = CxS.pValue(strcmp(CxS.Session, 'S1')&strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
S2_SvC = CxS.pValue(strcmp(CxS.Session, 'S2')&strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));

S_BLvS1 = SxC.pValue(strcmp(SxC.Condition, 'S')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S1'));
S_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'S')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S2'));
S_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'S')&strcmp(SxC.Session_1, 'S1')& strcmp(SxC.Session_2, 'S2'));
C_BLvS1= SxC.pValue(strcmp(SxC.Condition, 'C')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S1'));
C_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'C')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S2'));
C_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'C')&strcmp(SxC.Session_1, 'S1')& strcmp(SxC.Session_2, 'S2'));

% % within session comparisons
% BL_SvC = CxS.pValue(CxS.Session==0 & strcmp(CxS.Condition_1, 'S') & strcmp(CxS.Condition_2, 'C'));
% S1_SvC = CxS.pValue(CxS.Session==1 & strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
% S2_SvC = CxS.pValue(CxS.Session==2 &strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
%
% % between session comparisons
% S_BLvS1 = SxC.pValue(strcmp(SxC.Condition, 'S')&SxC.Session_1==0& SxC.Session_2==1);
% S_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'S')&SxC.Session_1==0& SxC.Session_2==2);
% S_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'S')&SxC.Session_1==1& SxC.Session_2==2);
% C_BLvS1= SxC.pValue(strcmp(SxC.Condition, 'C')&SxC.Session_1==0& SxC.Session_2==1);
% C_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'C')&SxC.Session_1==0& SxC.Session_2==2);
% C_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'C')&SxC.Session_1==1& SxC.Session_2==2);


% plot barplots
figure('units','normalized','outerposition',[0 0 .4 .4])
subplot(1, 3, 1)
PlotBars([ClassicMeans; SopMeans]', [ClassicSEM; SopSEM]', {'BL', 'S1', 'S2'}, Colors.Tasks.(Task))
legend({'Classic', 'Soporific'}, 'Location', 'southeast','AutoUpdate','off')
title([Task, ' ', Type])
ylabel(YLabel)

% plot significance
% (if I'm ever inspired, I'll make this automated; for now its manual)
comparisons = {
    [.9, 1.1], BL_SvC, [0 0 0];
    [1.9, 2.1], S1_SvC, [0 0 0];
    [2.9, 3.1], S2_SvC, [0 0 0];
    
    [.9, 1.9], C_BLvS1,[0 0 0];
    [1.1, 2.1], S_BLvS1, [0 0 0];
    [.9, 2.9], C_BLvS2, [0 0 0];
    [1.1, 3.1], S_BLvS2, [0 0 0];
    [1.9, 2.9], C_S1vS2,[0 0 0];
    [2.1, 3.1], S_S1vS2,[0 0 0]};

comparisons([comparisons{:, 2}]>=0.1, :) = [];
if size(comparisons, 1) > 0
    sigstar(comparisons(:, 1),[comparisons{:, 2}], comparisons(:, 3))
end


%%% plot effect sizes (with CIs?) of Session vs Condition
% uses the MES toolbox, so data needs to be restructured
ClassicTable = mat2table(ClassicMatrix, Participants, [1:3, 1:3]', ...
    'Participant', 'Session', 'Data');
ClassicTable.Condition = zeros(size(ClassicTable.Session));

SopoTable = mat2table(SopoMatrix, Participants, [1:3, 1:3]', ...
    'Participant', 'Session', 'Data');
SopoTable.Condition = ones(size(SopoTable.Session));
Table = [ClassicTable; SopoTable];

[stats, Table] = mes2way(Table.Data, [sort(Table.Session), Table.Condition], MES, ...
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
Hedges = nan(2, 3);
HedgesCI = nan(2, 3, 2);
for Indx = 1:3
    if Indx == 1
        Matrix = ClassicMatrix;
    elseif Indx ==2
        Matrix = SopoMatrix;
    else
        Matrix = (SopoMatrix +ClassicMatrix)./2;
    end
    
    statsHedges = mes(Matrix(:, 2), Matrix(:, 1), 'hedgesg', 'isDep', 1, 'nBoot', 1000);
    Hedges(1, Indx) = statsHedges.hedgesg;
    HedgesCI(1, Indx, :) = statsHedges.hedgesgCi;
    
    statsHedges = mes(Matrix(:, 3), Matrix(:, 2), 'hedgesg', 'isDep', 1, 'nBoot', 1000);
    Hedges(2, Indx) = statsHedges.hedgesg;
    HedgesCI(2, Indx, :) = statsHedges.hedgesgCi;
    
    
end

subplot(1, 3, 3)
PlotBars(Hedges(:, 1:2), HedgesCI(:, 1:2, :), {'BLvsS1','S1vsS2'},  Colors.Tasks.(Task) )
title(['Hedges g'])
ylim([-3 7])


saveas(gcf,fullfile(Figure_Path, [Type, '_Stats_', Task, '_timeXcondition.svg']))

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
% figure('units','normalized','outerposition',[0 0 .4 .4])
% PlotScales(ClassicMatrix, SopoMatrix, {'BL', 'S1', 'S2'}, {'Class', 'Sopo'})
% ylabel(YLabel)
% title([Task, ' ', Type, ' All Means'])
% saveas(gcf,fullfile(Figure_Path, [Type, '_', Task, '_timeANDcondition.svg']))

clc

%%% write out F values
disp(ranovatbl)
disp('**************************************************************')
disp(['for ', Type, '...'])
Comparison = {'intercept','Session', 'Condition', 'Interaction' };
for Indx = 2:4 % loop through session, condition and interaction
    % correct for sphericity
    MauchlyTest = mauchly(rm, c);
    if MauchlyTest.W(Indx) <.05
        Correction = 'GG';
    else
        Correction = '';
        DFm = ranovatbl.DF(Indx*2-1);
        DFr = ranovatbl.DF(Indx*2);
    end
    
    
    pValue = ranovatbl.(['pValue', Correction])(Indx*2-1);
    F = ranovatbl.F(Indx*2-1);
    
    
    if pValue < .05
        Negation = '';
    else
        Negation = 'NOT ';
    end
    
    disp(join(['There is ', Negation, 'an effect of ', Comparison{Indx}, ...
        '; F(', num2str(DFm), ', ', num2str(DFr), ') = ', num2str(F), ...
        ', p = ', num2str(pValue), '', ', eta2 = ', num2str(stats.(MES)(Indx-1))]))
end

Conditions = {'classic', 'soporific'};
for Indx = 1:2
    disp(['Hedges g for BL vs S1 in condition ', Conditions{Indx},' is: ', ...
        num2str(Hedges(1, Indx)), ' CI: ', num2str(HedgesCI(1, Indx, 1)), ' ', num2str(HedgesCI(1, Indx, 2)) ])
    disp(['Hedges g for S1 vs S2 in condition ', Conditions{Indx},' is: ', ...
        num2str(Hedges(2, Indx)), ' CI: ', num2str(HedgesCI(2, Indx, 1)), ' ', num2str(HedgesCI(2, Indx, 2))  ])
end

