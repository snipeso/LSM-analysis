clear
clc
close all


Stats_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DataPath = fullfile(Paths.Analysis, 'Statistics', 'ANOVA', 'Data'); % for statistics

Task = 'LAT';
Sessions = 'SD3'; % either SD3 or Sessions
SessionLabels = allSessionLabels.(Sessions);
% Data type

% Type = 'Misses';
% YLabel = '%';
% Loggify = false; % msybe?
% 
% Type = 'theta';
% YLabel = 'Power (log)';
% Loggify = true;

% Type = 'meanRTs';
% YLabel = 'RTs (log(s))';
% Loggify = false;

Type = 'KSS';
YLabel = 'VAS Score';
Loggify = false;


MES = 'eta2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



load(fullfile(DataPath, [Task, '_', Type, '_', Sessions, '.mat']))
if Loggify
    Matrix = log(Matrix);
end

% levene test on variance (maybe should be done after?)
Groups = repmat(1:size(Matrix, 2), size(Matrix, 1), 1);
Levenetest([Matrix(:), Groups(:)],.05)

% % z-score
for Indx_P = 1:numel(Participants)
    Matrix(Indx_P, :) = zscore(Matrix(Indx_P, :));
end

Means = nanmean(Matrix);
SEM = nanstd(Matrix)./sqrt(size(Matrix, 1));
Table = mat2table(Matrix, Participants, SessionLabels, 'Participant', [], Type);


Within = table();

Within.Session = SessionLabels;
% 
% 
% rm = fitrm(Table,[SessionLabels{1}, '-', SessionLabels{end},'~1'], 'WithinDesign',Within);
% 
% % test of sphericity
% % M = mauchly(rm);
% 
% [ranovatbl, ~, c] = ranova(rm, 'WithinModel', 'Session*Condition');
% SxC = multcompare(rm, 'Session', 'By', 'Condition');
% CxS = multcompare(rm, 'Condition', 'By', 'Session');
% 
% %%% manually assemble p-values
% 
% BL_SvC = CxS.pValue(strcmp(CxS.Session, 'B')&strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
% S1_SvC = CxS.pValue(strcmp(CxS.Session, 'S1')&strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
% S2_SvC = CxS.pValue(strcmp(CxS.Session, 'S2')&strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
% 
% S_BLvS1 = SxC.pValue(strcmp(SxC.Condition, 'S')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S1'));
% S_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'S')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S2'));
% S_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'S')&strcmp(SxC.Session_1, 'S1')& strcmp(SxC.Session_2, 'S2'));
% C_BLvS1= SxC.pValue(strcmp(SxC.Condition, 'C')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S1'));
% C_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'C')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S2'));
% C_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'C')&strcmp(SxC.Session_1, 'S1')& strcmp(SxC.Session_2, 'S2'));
% 
% % % within session comparisons
% % BL_SvC = CxS.pValue(CxS.Session==0 & strcmp(CxS.Condition_1, 'S') & strcmp(CxS.Condition_2, 'C'));
% % S1_SvC = CxS.pValue(CxS.Session==1 & strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
% % S2_SvC = CxS.pValue(CxS.Session==2 &strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
% % 
% % % between session comparisons
% % S_BLvS1 = SxC.pValue(strcmp(SxC.Condition, 'S')&SxC.Session_1==0& SxC.Session_2==1);
% % S_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'S')&SxC.Session_1==0& SxC.Session_2==2);
% % S_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'S')&SxC.Session_1==1& SxC.Session_2==2);
% % C_BLvS1= SxC.pValue(strcmp(SxC.Condition, 'C')&SxC.Session_1==0& SxC.Session_2==1);
% % C_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'C')&SxC.Session_1==0& SxC.Session_2==2);
% % C_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'C')&SxC.Session_1==1& SxC.Session_2==2);
% 
% 
% % plot barplots
% figure('units','normalized','outerposition',[0 0 .4 .4])
% subplot(1, 3, 1)
% PlotBars([ClassicMeans; SopMeans]', [SEM; SopSEM]', {'BL', 'S1', 'S2'})
% legend({'Classic', 'Soporific'}, 'Location', 'southeast','AutoUpdate','off')
% title([Task, ' ', Type])
% ylabel(YLabel)
% 
% Colors = plasma(3); % TODO, make this only once, and not in plotbars
% 
% % plot significance
% % (if I'm ever inspired, I'll make this automated; for now its manual)
% comparisons = {
%     [.9, 1.1], BL_SvC, [0 0 0];
%     [1.9, 2.1], S1_SvC, [0 0 0];
%     [2.9, 3.1], S2_SvC, [0 0 0];
%     
%     [.9, 1.9], C_BLvS1, Colors(1, :);
%     [1.1, 2.1], S_BLvS1, Colors(2, :);
%     [.9, 2.9], C_BLvS2, Colors(1, :);
%     [1.1, 3.1], S_BLvS2,  Colors(2, :);
%     [1.9, 2.9], C_S1vS2, Colors(1, :);
%     [2.1, 3.1], S_S1vS2, Colors(2, :)};
% 
% comparisons([comparisons{:, 2}]>=0.1, :) = [];
% if size(comparisons, 1) > 0
%     sigstar(comparisons(:, 1),[comparisons{:, 2}], comparisons(:, 3))
% end


%%% plot effect sizes (with CIs?) of Session vs Condition
% uses the MES toolbox, so data needs to be restructured
ClassicTable = mat2table(Matrix, Participants, [1:size(Matrix, 2)]', ...
    'Participant', 'Session', 'Data');
ClassicTable.Condition = zeros(size(ClassicTable.Session));

Table = [ClassicTable];

[stats, Table] = mes1way(Table.Data, MES, 'group', Table.Session, ...
    'isDep',1, 'nBoot', 1000);

% pairwise effect sizes
Hedges = nan(2, 3);
HedgesCI = nan(2, 3, 2);

statsHedges = mes(Matrix(:, 2), Matrix(:, 1), 'hedgesg', 'isDep', 1, 'nBoot', 1000);
Hedges(1, Indx) = statsHedges.hedgesg;
HedgesCI(1, Indx, :) = statsHedges.hedgesgCi;

statsHedges = mes(Matrix(:, 3), Matrix(:, 2), 'hedgesg', 'isDep', 1, 'nBoot', 1000);
Hedges(2, Indx) = statsHedges.hedgesg;
HedgesCI(2, Indx, :) = statsHedges.hedgesgCi;


subplot(1, 3, 3)
PlotBars(Hedges(:, 1:2), HedgesCI(:, 1:2, :), {'BLvsS1','S1vsS2'})
title(['Hedges g'])
ylim([-3 7])


saveas(gcf,fullfile(Paths.Figures, 'ESRSPoster', [Type, '_Stats_', Task, '_timeXcondition.svg']))

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
PlotScales(Matrix, SopoMatrix, {'BL', 'S1', 'S2'}, {'Class', 'Sopo'})
ylabel(YLabel)
title([Task, ' ', Type, ' All Means'])
saveas(gcf,fullfile(Paths.Figures, 'ESRSPoster', [Type, '_', Task, '_timeANDcondition.svg']))

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

