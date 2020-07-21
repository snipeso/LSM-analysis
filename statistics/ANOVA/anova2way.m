clear
clc
close all


Stats_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Task1 = 'AllTasks';

DataPath = fullfile(Paths.Analysis, 'statistics', 'Data', Task1); % for statistics

Task = Task1;

% Data type
% Types = {'Hits', 'Misses'};
% YLabels = {'%', '%'};
% Normalizations = [
%     false, false; % loggify
%     false, true % zscore
%     ];

% Types = {'Delta', 'Theta', 'Alpha', 'Beta'};
% YLabels = repmat({'Power Density'}, 1, numel(Types));
% Normalizations = [
%     false, true, false; % loggify
%     false, false, true % zscore
%     ];


% Types = {'meanRTs'};
% YLabels = {'Seconds'};
% Normalizations = [
%     false, false; % loggify
%     false, true % zscore
%     ];

% Types = {'KSS', 'Motivation', 'Effortful', 'Focused', 'Difficult'};
% YLabels = repmat({'VAS Score'}, 1, numel(Types));
% Normalizations = [
%     false, false; % loggify
%     false, true % zscore
%     ];


Types = {'miTot', 'miDuration', 'miStart'};
YLabels = {'Rate (#/min)', '%', 'Delay (s)'};
Normalizations = [
    false, false; % loggify
    false, true % zscore
    ];


MES = 'eta2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Figure_Path = fullfile(Paths.Figures, 'anova2way');

if ~exist(fullfile(Figure_Path), 'dir')
    mkdir(Figure_Path)
end

for Indx_T = 1:numel(Types)
    YLabel = YLabels{Indx_T};
    for Indx_N = 1:size(Normalizations, 2)
        Type = Types{Indx_T};
        Loggify = Normalizations(1, Indx_N);
        ZScore = Normalizations(2, Indx_N);
        ParticipantsLeft = Participants;
        
        TitleTag = [Task, '_', Type];
        
        YLabelNew = [YLabel];
        
        % load classic matrix
        load(fullfile(DataPath, [Task, '_', Type, '_Classic.mat']), 'Matrix')
        ClassicMatrix = Matrix;
        
        if Loggify
            if ~any(ClassicMatrix(:)<=0) % make sure all values are positive
                TitleTag = [TitleTag, '_log'];
                ClassicMatrix = log(ClassicMatrix); %TODO: figure out if this is OK
                YLabelNew = [YLabel, ' - log'];
            end
            
        end
        
        % load soporific matrix
        load(fullfile(DataPath, [Task, '_', Type, '_Soporific.mat']), 'Matrix')
        SopoMatrix = Matrix;
        
        if Loggify
            if ~any(SopoMatrix(:)<=0) % make sure all values are positive
                SopoMatrix = log(SopoMatrix);
            end
        end
        
        % handle nans
        Nans = any(isnan(ClassicMatrix), 2) | any(isnan(SopoMatrix), 2);
        if any(Nans)
            
            ParticipantsLeft(Nans) = [];
            ClassicMatrix(Nans, :) = [];
            SopoMatrix(Nans, :) = [];
        end
        
        % z-score
        if ZScore
            for Indx_P = 1:numel(ParticipantsLeft)
                All = zscore([ClassicMatrix(Indx_P, :), SopoMatrix(Indx_P, :)]);
                ClassicMatrix(Indx_P, :) = All(1:size(ClassicMatrix, 2));
                SopoMatrix(Indx_P, :) = All(size(ClassicMatrix, 2)+1:end);
            end
            
            TitleTag = [TitleTag, '_zscore'];
            YLabelNew = [YLabelNew, ' - zscored'];
        end
        
        % levene test on variance (maybe should be done after?)
        Groups = repmat([1 2 3], numel(ParticipantsLeft), 1);
        Levenetest([ClassicMatrix(:), Groups(:); SopoMatrix(:), 3+Groups(:)],.05)
        pause(2)
        
        % get mean and SEM for plots
        SopMeans = nanmean(SopoMatrix);
        SopSEM = std(SopoMatrix)./sqrt(size(SopoMatrix, 1));
        
        ClassicMeans = nanmean(ClassicMatrix);
        ClassicSEM = nanstd(ClassicMatrix)./sqrt(size(ClassicMatrix, 1));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% create table for MATLAB anova (used as basis for multiple comparisons)
        
        % convert to table
        Soporific = mat2table(SopoMatrix, ParticipantsLeft, {'s4', 's5', 's6'}, 'Participant', [], Type);
        Classic = mat2table(ClassicMatrix, ParticipantsLeft, {'s1', 's2', 's3'}, 'Participant', [], Type);
        
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
        ylabel(YLabelNew)
        box off
        set(gca, 'FontName', Format.FontName, 'FontSize',12)
        
        
        if size(comparisons, 1) > 0
            sigstar(comparisons(:, 1),[comparisons{:, 2}], comparisons(:, 3))
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% get effect sizes (with CIs?) of Session vs Condition
        % uses the MES toolbox, so data needs to be restructured
        
        
        ClassicTable = mat2table(ClassicMatrix, ParticipantsLeft, [1:size(ClassicMatrix, 2)]', ...
            'Participant', 'Session', 'Data');
        ClassicTable.Condition = zeros(size(ClassicTable.Session));
        
        SopoTable = mat2table(SopoMatrix, ParticipantsLeft, [1:size(SopoMatrix, 2)]', ...
            'Participant', 'Session', 'Data');
        SopoTable.Condition = ones(size(SopoTable.Session));
        
        Table = [ClassicTable; SopoTable];
        
        % get stats
        [stats, Table] = mes2way(Table.Data, [Table.Session, Table.Condition], MES, ...
            'fName',{'Session', 'Condition'}, 'isDep',[1 1], 'nBoot', 1000);
        
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
        PlotBars(Hedges(:, 1:2), HedgesCI(:, 1:2, :), {'BLvsS1','S1vsS2'},  ColorPair)
        title(['Hedges g'])
        set(gca, 'FontName', Format.FontName, 'FontSize',12)
        box off
        ylim([-3 5])
        
        saveas(gcf,fullfile(Figure_Path, [TitleTag, '_anova2way.svg']))
        
        
        % plot all values in same plot
        figure('units','normalized','outerposition',[0 0 .55 .4])
        PlotScales(ClassicMatrix, SopoMatrix, {'BL', 'S1', 'S2'}, {'Class', 'Sopo'}, [], Format)
        ylabel(YLabelNew)
        title([Task, ' ', Type, ' All Means'])
        set(gca, 'FontSize',12)
        box off
        saveas(gcf,fullfile(Figure_Path, [TitleTag, '_scales.svg']))
        
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
    end
end