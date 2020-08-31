function [Twoway, Pairwise] = anova2way(ClassicMatrix, SopoMatrix, Participants, Type, Task, TitleTag, YLabel, Figure_Path, Format)
% if format is skipped or empty, won't include plots

Twoway = struct();
Pairwise = struct();

MES = 'eta2';

% get mean and SEM for plots
SopMeans = nanmean(SopoMatrix);
SopSEM = std(SopoMatrix)./sqrt(size(SopoMatrix, 1));

ClassicMeans = nanmean(ClassicMatrix);
ClassicSEM = nanstd(ClassicMatrix)./sqrt(size(ClassicMatrix, 1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% create table for MATLAB anova (used as basis for multiple comparisons)

% convert to table
Soporific = mat2table(SopoMatrix, Participants, {'s4', 's5', 's6'}, 'Participant', [], Type);
Classic = mat2table(ClassicMatrix, Participants, {'s1', 's2', 's3'}, 'Participant', [], Type);

% create design tables
Between = [Classic, Soporific(:, 2:end)];
Within = table();

Within.Session = {'B'; 'S1'; 'S2'; 'B'; 'S1'; 'S2'};
Within.Condition = {'C'; 'C'; 'C'; 'S'; 'S'; 'S'};


% get model
rm = fitrm(Between,'s1-s6~1', 'WithinDesign',Within);

% test of sphericity
% M = mauchly(rm); TODO

% run stats
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

%%% plot pairwise plot
% (if I'm ever inspired, I'll make this automated; for now its manual)



if exist('Format', 'var') && ~isempty(Format)
    
    ColorPair = [   makePale(Format.Colors.Tasks.(Task));
        Format.Colors.Tasks.(Task)];
    
    % pairwise significance tests
    comparisons = {
        [.9, 1.1], BL_SvC, [0 0 0];
        [1.9, 2.1], S1_SvC, [0 0 0];
        [2.9, 3.1], S2_SvC, [0 0 0];
        
        [.9, 1.9], C_BLvS1, ColorPair(1, :);
        [1.1, 2.1], S_BLvS1,ColorPair(2, :);
        [.9, 2.9], C_BLvS2, ColorPair(1, :);
        [1.1, 3.1], S_BLvS2, ColorPair(2, :);
        [1.9, 2.9], C_S1vS2, ColorPair(1, :);
        [2.1, 3.1], S_S1vS2, ColorPair(2, :)};
    
    comparisons([comparisons{:, 2}]>=0.1, :) = [];
    
    % plot barplots
    figure('units','normalized','outerposition',[0 0 .55 .4])
    subplot(1, 3, 1)
    PlotBars([ClassicMeans; SopMeans]', [ClassicSEM; SopSEM]', {'BL', 'S1', 'S2'}, ColorPair)
    legend({'Classic', 'Soporific'}, 'Location', 'southeast','AutoUpdate','off')
    title([Task, ' ', Type])
    ylabel(YLabel)
    box off
    set(gca, 'FontName', Format.FontName, 'FontSize',12)
    
    
    if size(comparisons, 1) > 0
        sigstar(comparisons(:, 1),[comparisons{:, 2}]', comparisons(:, 3))
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get effect sizes (with CIs?) of Session vs Condition
% uses the MES toolbox, so data needs to be restructured


ClassicTable = mat2table(ClassicMatrix, Participants, [1:size(ClassicMatrix, 2)]', ...
    'Participant', 'Session', 'Data');
ClassicTable.Condition = zeros(size(ClassicTable.Session));

SopoTable = mat2table(SopoMatrix, Participants, [1:size(SopoMatrix, 2)]', ...
    'Participant', 'Session', 'Data');
SopoTable.Condition = ones(size(SopoTable.Session));

Table = [ClassicTable; SopoTable];

% get stats
[stats, Table] = mes2way(Table.Data, [Table.Session, Table.Condition], MES, ...
    'fName',{'Session', 'Condition'}, 'isDep',[1 1], 'nBoot', 1000);

if exist('Format', 'var') && ~isempty(Format)
    %%% plot effect sizes
    subplot(1, 3, 2)
    hold on
    bar(1:3, stats.(MES), 'FaceColor', [.5 .5 .5], 'LineStyle', 'none')
    errorbar(1:3, stats.(MES), stats.(MES)-stats.([MES, 'Ci'])(:, 1),  stats.([MES, 'Ci'])(:, 2)-stats.(MES), ...
        'Color', 'k', 'LineStyle', 'none', 'LineWidth', 2 )
    
    xticks(1:3)
    set(gca, 'FontName', Format.FontName, 'FontSize',12)
    xticklabels({'Session', 'Condition', 'Interaction'})
    box off
    xlim([.5, 3.5])
    ylim([0 1])
    title(['ANOVA effect size: ', MES])
    
    % plot significance
    pValues = [cell2mat(Table( 3:5,6)), [1:3]'];
    pValues(pValues(:, 1)>.1, :) = [];
    for Indx = 1:size(pValues, 1)
        sigstar({[pValues(Indx, 2)-.1, pValues(Indx, 2)+.1]},[pValues(Indx, 1)], {[0 0 0]})
    end
    
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

if exist('Format', 'var') && ~isempty(Format)
    subplot(1, 3, 3)
    PlotBars(Hedges(:, 1:2), HedgesCI(:, 1:2, :), {'BLvsS1','S1vsS2'},  ColorPair)
    title(['Hedges g'])
    set(gca, 'FontName', Format.FontName, 'FontSize',12)
    box off
    ylim([-3 5])
    
    saveas(gcf,fullfile(Figure_Path, [TitleTag, '_anova2way.svg']))
    
    
    % plot all values in same plot
    figure('units','normalized','outerposition',[0 0 .55 .4])
    PlotScales(ClassicMatrix, SopoMatrix, {'BL', 'S1', 'S2'}, {'Class', 'Sopo'}, [], Format)
    ylabel(YLabel)
    title([Task, ' ', Type, ' All Means'])
    set(gca, 'FontSize',12)
    box off
    saveas(gcf,fullfile(Figure_Path, [TitleTag, '_scales.svg']))
    
end
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