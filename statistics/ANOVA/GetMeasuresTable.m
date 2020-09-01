
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
    'Difficult','miTot', 'miDuration', 'miStart'
    };

Normalizations = {true, false};

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
    
    
    
    %%% save to table
    if ZScore
        Norm = '_zscored';
    else
        Norm = '';
    end
    
    Tablename = [Analysis, '_Twoway', Norm,'.csv'];
    writetable(Twoway, fullfile(Destination, Tablename), 'WriteRowNames',true)
    
    Tablename = [Analysis,  '_Pairwise', Norm,'.csv'];
    writetable(Twoway, fullfile(Destination, Tablename), 'WriteRowNames',true)
    
end