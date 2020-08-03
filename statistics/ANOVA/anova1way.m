
clear
clc
% close all


Stats_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Task = 'LAT';
% Measures = {'Hits', 'Late', 'Misses',  'Q1Q4RTs', 'MeanRTs', 'KSS'};

Task = 'PVT';
Measures = {'Lapses', 'MeanRTs', 'Bottom20', 'Q1Q4RTs', 'KSS'};


DataPath = fullfile(Paths.Analysis, 'statistics', 'Data', Task); % for statistics



Normalizations = [
    false, false; % loggify
    false, true % zscore
    ];

MES = 'eta2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Figure_Path = fullfile(Paths.Figures, 'anova1way');

if ~exist(fullfile(Figure_Path), 'dir')
    mkdir(Figure_Path)
end

for Indx_N = 1:size(Normalizations, 2)
            Loggify = Normalizations(1, Indx_N);
        ZScore = Normalizations(2, Indx_N);
        
    ES = nan(numel(Measures), 2);
    CI = nan(numel(Measures), 2, 2);
    Correction = '';
    if Loggify
        Correction = [Correction, ' log'];
    end
    
    if ZScore
        Correction = [Correction, ' zscored'];
    end
    
    for Indx_M = 1:numel(Measures)
        
        
        Measure = Measures{Indx_M};
        Loggify = Normalizations(1, Indx_N);
        ZScore = Normalizations(2, Indx_N);
        ParticipantsLeft = Participants;
        
        
        
        % load classic matrix
        load(fullfile(DataPath, [Task, '_', Measure, '_Classic.mat']), 'Matrix')
        ClassicMatrix = Matrix;
        
        if Loggify
            if ~any(ClassicMatrix(:)<=0) % make sure all values are positive
                
                ClassicMatrix = log(ClassicMatrix); %TODO: figure out if this is OK
                
            end
            
        end
        
        % load soporific matrix
        load(fullfile(DataPath, [Task, '_', Measure, '_Soporific.mat']), 'Matrix')
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
        end
        
        
        [stats, Table] = mes1way(SopoMatrix, MES,'isDep',1, 'nBoot', 1000);
        
        ES(Indx_M, 1) = stats.(MES);
        CI(Indx_M, 1, :) = stats.([MES, 'Ci']);
        
        [stats, Table] = mes1way(ClassicMatrix, MES,'isDep',1, 'nBoot', 1000);
        ES(Indx_M, 2) = stats.(MES);
        CI(Indx_M, 2, :) = stats.([MES, 'Ci']);
        
    end
    figure
    PlotBars(ES, CI, Measures, [Format.Colors.Generic.Red;Format.Colors.Generic.Dark1], 'horizontal')
    xlim([0 1])
    legend({ 'Soporific', 'Classic'})
    set(gca, 'FontName', Format.FontName, 'FontSize', 12)
    xlabel(['Effect Size (', MES, ')'])
    title([Task, ' effect sizes', Correction])
    
    saveas(gcf,fullfile(Figure_Path, ['EffectSize', Correction, '.svg']))
end


