clear
clc
close all


wp_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Normalization = 'zscore';


Tag = 'PowerPeaks';
Hotspot = 'Hotspot'; % TODO: make sure this is in apporpriate figure name

Channels_10_20 = [72 11 45];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TitleTag = strjoin({Tag, Normalization, 'All'}, '_');

Tasks =  Format.Tasks.BAT;
RRT = Format.Tasks.RRT;
TasksLabels = Format.Labels.BAT;
RRTLabels = Format.Labels.RRT;


Sessions_BAT = Format.Labels.(Tasks{1}).BAT.Sessions;
Sessions_RRT = Format.Labels.(RRT{1}).RRT.Sessions;

SessionLabels_BAT =  Format.Labels.(Tasks{1}).BAT.Plot;
SessionLabels_RRT =  Format.Labels.(RRT{1}).RRT.Plot;

CompareTaskSessions = {'Baseline', 'Session2'};


Paths.Results = string(fullfile(Paths.Results, Tag, 'AllTasks'));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end


switch Normalization
    case 'log'
        YLabel = 'Log Power Density';
    case 'zscore'
        YLabel = 'Power Density (z scored)';
    otherwise
        YLabel = 'Power Density';
end


%%%%%%%%%%%%%%
%%% Load data






for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};
    PeaksPath = fullfile(Paths.Summary, [Task, '_BAT_PowerPeaks.mat']);
    load(PeaksPath, 'PowerPeaks', 'PowerPeaks_Hotspot', ...
        'Freqs', 'Chanlocs')
    
    
    if Indx_T == 1
        AllPowerPeaks_Tasks = PowerPeaks;
        
    else
        Variables = fieldnames(PowerPeaks);
        
        for Indx_V = 1:numel(Variables)
            AllPowerPeaks_Tasks.(Variables{Indx_V}) = ...
                cat(4,  AllPowerPeaks_Tasks.(Variables{Indx_V}), ...
                PowerPeaks.(Variables{Indx_V}) );
        end
    end
end


for Indx_R = 1:numel(RRT)
    Task = RRT{Indx_R};
    PeaksPath = fullfile(Paths.Summary, [Task, '_RRT_PowerPeaks.mat']);
    load(PeaksPath, 'PowerPeaks', 'PowerPeaks_Hotspot', ...
        'Freqs', 'Chanlocs')
    
    
    if Indx_R == 1
        AllPowerPeaks_RRT = PowerPeaks;
        
    else
        Variables = fieldnames(PowerPeaks);
        
        for Indx_V = 1:numel(Variables)
            AllPowerPeaks_RRT.(Variables{Indx_V}) = ...
                cat(4,  AllPowerPeaks_RRT.(Variables{Indx_V}), ...
                PowerPeaks.(Variables{Indx_V}) );
        end
    end
end




for Indx_V = 1:numel(Variables)
    V = Variables{Indx_V};
    % z-score the data
    if strcmp(Normalization, 'zscore')
        for Indx_P = 1:numel(Participants)
            TaskData =    AllPowerPeaks_Tasks.(V)(Indx_P, :, :);
            RRTData =    AllPowerPeaks_RRT.(V)(Indx_P, :, :);
            Mean = nanmean([TaskData(:); RRTData(:)]);
            STD =  nanstd([TaskData(:); RRTData(:)]);
            AllPowerPeaks_Tasks.(V)(Indx_P, :, :) = (TaskData-Mean)./STD;
            AllPowerPeaks_RRT.(V)(Indx_P, :, :) = (RRTData-Mean)./STD;
        end
    end
    
    
    % get BL vs SD data
    BLAll.(V) =  squeeze(AllPowerPeaks_Tasks.(V)(:, 1, :, :));
    
    BL_RRT = AllPowerPeaks_RRT.(V)(:, contains(Sessions_RRT, {'BaselinePost', 'MainPost'}), :, :);
    BLAll.(V) = cat(3, BLAll.(V),  squeeze(nanmean(BL_RRT, 2)));
    
    SDAll.(V) =  squeeze(AllPowerPeaks_Tasks.(V)(:, 3, :, :));
    
    SD_RRT = AllPowerPeaks_RRT.(V)(:, contains(Sessions_RRT, {'Main7', 'Main8'}), :, :);
    SDAll.(V) = cat(3, SDAll.(V),  squeeze(nanmean(SD_RRT, 2)));
end

    %%% Plots & Stats

    
    
AllTasks = [Tasks, RRT];
AllTasksLabels = [TasksLabels, RRTLabels];
CLims = [-5 5];
Low = -2;
Scale = 100;

    Colors = [];
    
    for Indx_T = 1:numel(AllTasks)
        Colors = cat(1, Colors, Format.Colors.Tasks.(AllTasks{Indx_T})) ;
    end
    
for Indx_V = 1:numel(Variables)
    V = Variables{Indx_V};
    % plot change from BL of all topos of all sessions
    % tasks
    figure('units','normalized','outerposition',[0 0 1 .4])
    Indx = 1;
    for Indx_ST = 2:3
        for Indx_T = 1:numel(Tasks)
            subplot(2, numel(Tasks), Indx)
            M1 = squeeze( AllPowerPeaks_Tasks.(V)(:, 1, :, Indx_T)); % baseline session
            M2 = squeeze( AllPowerPeaks_Tasks.(V)(:, Indx_ST, :, Indx_T));
            PlotTopoDiff(M1, M2, Chanlocs, CLims, Format)
            title([TasksLabels{Indx_T}, ' ', V, ' ', SessionLabels_BAT{Indx_ST}])
            
            Indx = Indx+1;
        end
    end
    saveas(gcf,fullfile(Paths.Results, [TitleTag, ' ', V,  '_TasksTopoDiff.svg']))
    
    
    % RRT
    figure('units','normalized','outerposition',[0 0 1 1])
    Indx = 1;
    for Indx_T = 1:numel(RRT)
        for Indx_SR = [1, 3:numel(Sessions_RRT)]
            subplot(numel(RRT), numel(Sessions_RRT)-1, Indx)
            M1 = squeeze(AllPowerPeaks_RRT.(V)(:, 2, :, Indx_T)); % baseline session
            M2 = squeeze(AllPowerPeaks_RRT.(V)(:, Indx_SR, :, Indx_T));
            PlotTopoDiff(M1, M2, Chanlocs, CLims, Format)
            colorbar off
            title([RRTLabels{Indx_T}, ' ', V, ' ', SessionLabels_RRT{Indx_SR}])
            
            Indx = Indx+1;
        end
    end
    saveas(gcf,fullfile(Paths.Results, [TitleTag,  ' ', V, '_RRTTopoDiff.svg']))
    
    % if option, plot single topos
    
    % tasks
    figure('units','normalized','outerposition',[0 0 1 .4])
    Indx = 1;
    for Indx_ST = 1:3
        for Indx_T = 1:numel(Tasks)
            subplot(3, numel(Tasks), Indx)
            M = squeeze( nanmean(AllPowerPeaks_Tasks.(V)(:, Indx_ST, :, Indx_T), 1));
            topoplot(M, Chanlocs, 'style', 'map', 'headrad', 'rim', ...
                'gridscale', Scale)
            colorbar
            colormap(Format.Colormap.Linear)
            
            title([TasksLabels{Indx_T}, ' ', V, ' ', Sessions_BAT{Indx_ST}])
            
            Indx = Indx+1;
        end
    end
    saveas(gcf,fullfile(Paths.Results, [TitleTag, ' ', V,  '_TasksTopos.svg']))
    
    
    % RRT
    figure('units','normalized','outerposition',[0 0 1 1])
    Indx = 1;
    for Indx_T = 1:numel(RRT)
        for Indx_SR = 1:numel(Sessions_RRT)
            subplot(numel(RRT), numel(Sessions_RRT), Indx)
            
            M = squeeze(nanmean(AllPowerPeaks_RRT.(V)(:, Indx_SR, :, Indx_T), 1));
            topoplot(M, Chanlocs, 'style', 'map', 'headrad', 'rim', ...
                'gridscale', Scale)
            colormap(Format.Colormap.Linear)
            colorbar
            
            title([RRTLabels{Indx_T}, ' ', V, ' ', Sessions_RRT{Indx_SR}])
            
            Indx = Indx+1;
        end
    end
    saveas(gcf,fullfile(Paths.Results, [TitleTag,  ' ', V, '_RRTTopos.svg']))
    
    
    
    % plot diff from fixation
    
    Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
        %%% Effect Sizes
    BL_SD_Hotspot = struct();
    for Indx_T = 1:numel(AllTasks)
        BL = squeeze(nanmean(BLAll.(V)(:, Indexes_Hotspot, Indx_T), 2));
        SD2 = squeeze(nanmean(SDAll.(V)(:,Indexes_Hotspot, Indx_T), 2));
        statsHedges = mes( SD2, BL, 'hedgesg', 'isDep', 1, 'nBoot', 1000);
        BL_SD_Hotspot(Indx_T).task = AllTasks{Indx_T};
        BL_SD_Hotspot(Indx_T).p = statsHedges.t.p;
        BL_SD_Hotspot(Indx_T).HedgesG = statsHedges.hedgesg;
        BL_SD_Hotspot(Indx_T).HedgesCI_Low = statsHedges.hedgesgCi(1);
        BL_SD_Hotspot(Indx_T).HedgesCI_High = statsHedges.hedgesgCi(2);
        
        % TODO: normality tests?
        
    end
    
    
    BL_SD_Hotspot = struct2table(BL_SD_Hotspot);
    BL_SD_Hotspot.fdr_p = fdr(BL_SD_Hotspot.p);
    
    writetable(BL_SD_Hotspot, fullfile(Paths.Results, [TitleTag, '_', Hotspot, '_', V, '_EffectSizes.csv']));
    
    % correct for multiple comparisons
    
    figure('units','normalized','outerposition',[0 0 .5 .5])
    PlotBars(BL_SD_Hotspot.HedgesG, [BL_SD_Hotspot.HedgesCI_Low,BL_SD_Hotspot.HedgesCI_High ], AllTasksLabels, Colors, 'vertical', Format)
    ylabel('Hedges g')
    set(gca, 'FontSize', 12)
    title([V, ' ', Normalization])
    saveas(gcf,fullfile(Paths.Results, [TitleTag, '_', V, '_SD2-BL_EffectSizes.svg']))
end
