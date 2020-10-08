
clear
clc
close all


Stats_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Tasks = {'LAT', 'PVT'};

Types = { 'Delta', 'Theta', 'Alpha', 'Beta';
    'backDelta', 'backTheta', 'backAlpha', 'backBeta';
    'Hits', 'Misses', 'Late', 'Lapses-FA' ;
    'FA', 'Lapses', 'meanRTs', 'medianRTs';
    'stdRTs', 'Q1Q4RTs', 'Top10', 'Bottom10';
    'KSS', 'Motivation', 'Effortful', 'Focused';
    'Difficult','miTot', 'miDuration', 'miStart';
    'rP300mean', 'sP300mean', '',''
    };
PlotShortYLabels = flip({'KSS', 'Theta', 'miDuration', 'Lapses', 'meanRTs'});
PlotLongYLabels = {'Top10', 'medianRTs', 'meanRTs','Late','Bottom10','Q1Q4RTs','stdRTs','Lapses-FA','Lapses','Hits','miTot','Difficult','Misses','miDuration','Delta','Beta','Motivation','Theta','KSS' };

Normalizations = {true, false};
Flip = {'Motivation', 'Hits'};

Analysis = 'classicVsoporific';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Types = Types(:)';

Destination = fullfile(Paths.Preprocessed, 'Statistics', Analysis, 'Tables');


if ~exist(Destination, 'dir')
    mkdir(Destination)
end



for Indx_N = 1:numel(Normalizations)
    
    ZScore = Normalizations{Indx_N};
    Twoway = table();
    Pairwise = table();
    
    for Indx_T = 1:numel(Tasks)
        Task = Tasks{Indx_T};
        DataPath = fullfile(Paths.Preprocessed, 'Statistics', Analysis, Task); % for statistics
        
        TwowayTask = table();
        PairwiseTask = table();
        
        for Indx_Ty = 1:numel(Types)
            Type = Types{Indx_Ty};
            if isempty(Type)
                continue
            end
            
            ParticipantsLeft = Participants;
            
            
            % load classic matrix
            load(fullfile(DataPath, [Task, '_', Type, '_Classic.mat']), 'Matrix')
            ClassicMatrix = Matrix;
            
            % load soporific matrix
            load(fullfile(DataPath, [Task, '_', Type, '_Soporific.mat']), 'Matrix')
            SopoMatrix = Matrix;
            
            
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
                
            end
            
            if  ismember(Type, Flip)
                ClassicMatrix = -ClassicMatrix;
                SopoMatrix = -SopoMatrix;
            end
            
            [T, P] = anova2way(ClassicMatrix, SopoMatrix, ...
                ParticipantsLeft, Type, Task);
            
            %             TwowayTask = cat(1, Twoway, struct2table(T));
            %             PairwiseTask = cat(1, Pairwise, struct2table(P));
            
            TwowayTask = cat(1, TwowayTask, T);
            PairwiseTask = cat(1, PairwiseTask, P);
            
        end
        
        
        Twoway = cat(2, Twoway, TwowayTask);
        Pairwise = cat(2, Pairwise,  PairwiseTask);
        
    end
    
    
    
    %%% Get extra columns needed for sorting
    
    % get difference between session and condition
    SessionEta = (Twoway.SessionEta_LAT + Twoway.SessionEta_PVT)/2;
    ConditionEta = (Twoway.ConditionEta_LAT + Twoway.ConditionEta_PVT)/2;
    Twoway.Difference = SessionEta - ConditionEta;
    
    [~,ii]=sort( Twoway.Difference,'Descend');
    [~,Twoway.DiffOrder]=sort(ii);
    
    % set order to 0 for measures without any significant effects of
    % session
    Twoway.DiffOrder(Twoway.SessionP_LAT > .05 & Twoway.SessionP_PVT > .05) = 0;
    Twoway.OriginalOrder = [1:numel(Twoway.DiffOrder)]';
    
    % flip condition for plotting
    Twoway.fConditionEta_LAT = -Twoway.ConditionEta_LAT;
    Twoway.fConditionEta_PVT = -Twoway.ConditionEta_PVT;
    
    
    
    
    %%% save to table
    if ZScore
        Norm = '_zscored';
    else
        Norm = '';
    end
    
    Tablename = [Analysis, '_Twoway', Norm,'.csv'];
    writetable(Twoway, fullfile(Destination, Tablename), 'WriteRowNames',true)
    
    Tablename = [Analysis,  '_Pairwise', Norm,'.csv'];
    writetable(Pairwise, fullfile(Destination, Tablename), 'WriteRowNames',true)
    
    
    PlotComparisons = {'BLvSD1', 'SD1vSD2'};
    YLabels = {PlotShortYLabels, PlotLongYLabels};
    
    for Indx_PL = 1:numel(PlotComparisons)
        for Indx_YL = 1:numel(YLabels)
            figure
            % plot 0 line
            YLabel = YLabels{Indx_YL};
            MiddleCols = {['LAT_Classic_', PlotComparisons{Indx_PL}, 'G'], ['LAT_Soporific_', PlotComparisons{Indx_PL}, 'G'],...
                ['PVT_Classic_', PlotComparisons{Indx_PL}, 'G'], ['PVT_Soporific_', PlotComparisons{Indx_PL}, 'G']};
            
            LowEndCols = replace(MiddleCols, 'G', 'C1');
            HighEndCols = replace(MiddleCols, 'G', 'C2');
            Colors =  GetColors(YLabel, MiddleCols, Format);
            plot([0 0], [0, numel(YLabel)+1], 'k')
            PlotRanges(Pairwise{YLabel, MiddleCols}, Pairwise{YLabel, LowEndCols}, Pairwise{YLabel, HighEndCols}, YLabel, [], Colors, Format)
            xlim([-2, 5])
            ylim([0  numel(YLabel)+1])
            set(gca, 'FontSize', 12)
            title([PlotComparisons{Indx_PL}, Norm])
            
        end
    end
    
    
    
end


function Colors = GetColors(Types, Labels, Format)
Colors = cell(numel(Types), numel(Labels));
Labels = split(Labels', '_');
Tasks = Labels(:, 1);
Conditions = Labels(:, 2);
for Indx_T = 1:numel(Types)
    for Indx_L = 1:size(Labels, 1)
        %         Category = Format.Colors.Measures.(Types{Indx_T});
        Category = Format.MeasuresDict(Types{Indx_T});
        Colors{Indx_T, Indx_L} = Format.Colors.(Category).(Tasks{Indx_L}).(Conditions{Indx_L});
    end
end
end