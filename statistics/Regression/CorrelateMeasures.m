
clear
clc
close all

run(fullfile(extractBefore(mfilename('fullpath'), 'statistics'), 'General_Parameters'))

% Options:
% - zscore or other corection
% - which tasks or sessions to use
% - parametric or non-parametric
% - correct for session or not (subtract session average)
% - correct for task or not?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'PVT', 'LAT'};
% TaskName = Tasks{1};
TaskName = 'AllTasks';

PlotMeasures = {'Top10', 'medianRTs', 'meanRTs','Late','Bottom10','Q1Q4RTs','stdRTs','Lapses-FA','Lapses','Hits','miTot','Difficult','Misses','miDuration','Delta','Beta','Motivation','Theta','KSS' };

Conditions = {'Classic', 'Soporific'};

SessionLabels = allSessionLabels.Basic; % TODO: eventually make this info saved in the matrices

Normalize = 'zscoreP'; %'zscoreS&P' 'zscoreP', 'none'
Title = 'All Measures';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Regression_Parameters

Paths.Figures = fullfile(Paths.Figures, 'Regression');
if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end

All_Measures_T = table();
Participant_Labels = repmat(Participants, 1, numel(SessionLabels))';
Session_Labels = reshape(repmat(SessionLabels, numel(Participants), 1), [], 1);

All_Measures_M = nan(numel(SessionLabels)*numel(Participants)*numel(Tasks)*numel(Conditions), numel(PlotMeasures));
% assemble the data as a matrix of every measure
% PVT - Classic
% PVT - Soporific
% LAT - Classic
% LAT - Soporific
for Indx_M = 1:numel(PlotMeasures)
    T = table();
    for Indx_T = 1:numel(Tasks)
        
        for Indx_C = 1:numel(Conditions)
            T_temp = table();
            DataPath = fullfile(Paths.Data, 'Statistics', 'classicVsoporific', Tasks{Indx_T}, ...
                [Tasks{Indx_T}, '_', PlotMeasures{Indx_M}, '_', Conditions{Indx_C}, '.mat']);
            load(DataPath, 'Matrix')
            
            % assemble into a section of table
            T_temp.Participant = Participant_Labels;
            T_temp.Session = Session_Labels;
            T_temp.Task = cellstr(repmat(Tasks{Indx_T}, numel(Participant_Labels), 1));
            T_temp.Condition = cellstr(repmat(Conditions{Indx_C}, numel(Participant_Labels), 1));
            T_temp.(PlotMeasures{Indx_M}) = Matrix(:);
            
            % append to final table
            T = [T; T_temp];
        end
    end
    
    
    
    
    All_Measures_T.Participant = T.Participant; % NOTE: this is just a mindless way of making sure the labels are correct
    All_Measures_T.Session = T.Session;
    All_Measures_T.Task = T.Task;
    All_Measures_T.Condition = T.Condition;
    
    AllData =  T.(PlotMeasures{Indx_M});
    % z-score
    switch Normalize
        case 'zscoreS&P'
            ScatterGroup = 'Condition';
            for Indx_P = 1:numel(Participants)
                for Indx_S = 1:numel(SessionLabels)
                    Indexes =  strcmp(All_Measures_T.Participant, Participants{Indx_P}) & strcmp(All_Measures_T.Session, SessionLabels{Indx_S});
                    All = zscore(AllData(Indexes));
                    AllData(Indexes) = All;
                end
            end
            
            ScatterColors = [makePale(Format.Colors.Tasks.(TaskName)); Format.Colors.Tasks.(TaskName)];
        case 'zscoreP'
            ScatterGroup = 'Session';
            for Indx_P = 1:numel(Participants)
                
                Indexes =  strcmp(All_Measures_T.Participant, Participants{Indx_P});
                All = zscore(AllData(Indexes));
                AllData(Indexes) = All;
                
            end
            
            ScatterColors = Format.Colors.Sessions;
        otherwise
            ScatterGroup = 'Participant';
            ScatterColors = [];
    end
    
    
    
    All_Measures_T.(PlotMeasures{Indx_M}) =AllData;
    All_Measures_M(:, Indx_M) =  AllData;
end


TitleTag = [TaskName, '_', Normalize];

[R,P, CI_Low, CI_Up] = corrcoef( All_Measures_M, 'Rows','pairwise');
figure('units','normalized','outerposition',[0 0 .4 .7])
PlotCorr(R, [], PlotMeasures, Format)
title([Title, ' R values of all parameters ', Normalize])
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_CorrelateAll_uncorrected.svg']))

figure('units','normalized','outerposition',[0 0 .4 .7])
PlotCorr(R, P, PlotMeasures, Format)
title([Title, ' R values of all parameters, p<.05 corrected ', Normalize])
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_CorrelateAll_Pcorrected.svg']))

figure('units','normalized','outerposition',[0 0 .4 .7])
[~,h] = fdr(P, 0.05);
PlotCorr(R, h, PlotMeasures, Format)
title([Title, ' R values of all parameters, fdr corrected  ', Normalize])
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_CorrelateAll_FDRcorrected.svg']))


ThetaIndx = find(strcmpi(PlotMeasures, 'Theta'));
miDurIndx = find(strcmpi(PlotMeasures, 'miDuration'));


% plot bars of R values for theta vs microsleeps
figure('units','normalized','outerposition',[0 0 1, .5])
Errors = cat(3, CI_Low(:,  [ThetaIndx, miDurIndx]), CI_Up(:,  [ThetaIndx, miDurIndx]));
PlotBars(R(:, [ThetaIndx, miDurIndx]), Errors, PlotMeasures, cat(1,Format.Colors.Generic.Red, Format.Colors.Generic.Pale3))
y = R(ThetaIndx, miDurIndx);
y = [y, y];
hold on
x = get(gca, 'xlim');
plot(x, y, ':', 'Color', [.5 .5 .5])
plot(x, -y, ':', 'Color', [.5 .5 .5])
ylim([-1 1])
ylabel('R')
title(['Theta vs Microsleep Duration R values ', Normalize])
legend({'Theta', 'Microsleep Duration (%)'})
set(gca, 'FontName', Format.FontName, 'FontSize', 13)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_R_Theta_v_MiDur.svg']))




% plot bars of R values for theta vs microsleeps

KSSIndx = find(strcmpi(PlotMeasures, 'KSS'));
RTIndx = find(strcmpi(PlotMeasures, 'meanRTs'));

figure('units','normalized','outerposition',[0 0 1, .5])
Errors = cat(3, CI_Low(:,  [KSSIndx,RTIndx]), CI_Up(:,  [KSSIndx, RTIndx]));
PlotBars(R(:, [KSSIndx, RTIndx]), Errors, PlotMeasures, cat(1,Format.Colors.Generic.Red, Format.Colors.Generic.Pale3))
y = R(KSSIndx, RTIndx);
y = [y, y];
hold on
x = get(gca, 'xlim');
plot(x, y, ':', 'Color', [.5 .5 .5])
plot(x, -y, ':', 'Color', [.5 .5 .5])
ylim([-1 1])
ylabel('R')
title(['Subjective Sleepiness vs Reaction Times R values ', Normalize])
legend({'KSS', 'mean RT'})
set(gca, 'FontName', Format.FontName, 'FontSize', 13)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_R_KSS_v_RTs.svg']))

LapseIndx =  find(strcmpi(PlotMeasures, 'Lapses'));
figure('units','normalized','outerposition',[0 0 1, .5])
Errors = cat(3, CI_Low(:,  [KSSIndx,RTIndx, LapseIndx]), CI_Up(:,  [KSSIndx, RTIndx, LapseIndx]));
PlotBars(R(:, [KSSIndx, RTIndx, LapseIndx]), Errors, PlotMeasures, cat(1,Format.Colors.Generic.Red, Format.Colors.Generic.Dark1, Format.Colors.Generic.Dark2))
ylim([-1 1])
ylabel('R')
title(['Subjective Sleepiness vs Reaction Times vs Lapses R values ', Normalize])
legend({'KSS', 'mean RT', 'Lapses'})
set(gca, 'FontName', Format.FontName, 'FontSize', 13)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_R_KSS_v_RTs_v_lapses.svg']))



PlotGroups = [true, false];

for Plotting = PlotGroups
    if Plotting
        TitleTag = [TaskName, '_', Normalize, '_PlotGroups'];
        ScatterColorsTemp = ScatterColors;
    else
        TitleTag = [TaskName, '_', Normalize];
        ScatterColorsTemp = 0;
    end
    
    figure('units','normalized','outerposition',[0 0 1 1])
    FigIndx = 1;
    Indx = 1;
    for Indx_X = 1:numel(PlotMeasures)
        for Indx_Y = Indx_X+1:numel(PlotMeasures)
            
            if Indx > 3*5 % loop through subplots until run out, then start new figure
                saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_ScatterAll', num2str(FigIndx),'.svg']))
                figure('units','normalized','outerposition',[0 0 1 1])
                Indx = 1;
                FigIndx = FigIndx + 1;
            end
            subplot(3, 5, Indx)
            PlotConfetti(All_Measures_M(:, Indx_X), All_Measures_M(:, Indx_Y), ...
                All_Measures_T.(ScatterGroup), Format, [], ScatterColorsTemp)
            xlabel(PlotMeasures{Indx_X})
            ylabel(PlotMeasures{Indx_Y})
            title(['R=', num2str(R(Indx_X, Indx_Y), '%.2f'), ' p=', num2str(P(Indx_X, Indx_Y), '%.2f')])
            Indx = Indx+1;
        end
        
    end
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_ScatterAll', num2str(FigIndx), '.svg']))
    
    
    
    %%% plot scatter of theta vs microsleeps
    figure('units','normalized','outerposition',[0 0 .4 .7])
    PlotConfetti(All_Measures_M(:, ThetaIndx), All_Measures_M(:, miDurIndx), ...
        All_Measures_T.(ScatterGroup), Format, 40, ScatterColorsTemp)
    xlabel('Theta')
    ylabel('Microsleep Duration (%)')
    
    title(['Correlation Theta and Microsleeps (R=', num2str(R(ThetaIndx, miDurIndx), '%.2f'),...
        ' p=', num2str(P(ThetaIndx, miDurIndx), '%.2f'), ' ', Normalize, ')'])
    set(gca, 'FontName', Format.FontName, 'FontSize', 16)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_Corr_Theta_v_MiDur.svg']))
end


