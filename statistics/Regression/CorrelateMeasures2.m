
clear
clc
close all

Regression_Parameters
% Options:
% - zscore or other corection
% - which tasks or sessions to use
% - parametric or non-parametric
% - correct for session or not (subtract session average)
% - correct for task or not?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Normalization = 'zscoreP'; %'zscoreS&P' 'zscoreP', 'none'
% Normalization = 'none'; %'zscoreS&P' 'zscoreP', 'none'

% Condition = 'BAT';
% 
% Plot = struct();
% Plot.Power = {'Hotspot_Delta', 'Hotspot_Theta', 'Hotspot_Alpha', 'Hotspot_Beta'};
% Plot.Questionnaires = {'KSS', 'Difficult', 'Effortful', 'Focused', 'Motivation', 'Relaxing'};
% Plot.PowerPeaks = {'Hotspot_Amplitude', 'Hotspot_Peak', 'Hotspot_Slope', 'Hotspot_Intercept', 'Hotspot_FWHM' };


% Condition = 'BAT';
% 
% Plot = struct();
% Plot.Power = {'Hotspot_Delta', 'Hotspot_Theta', 'Hotspot_Alpha', 'Hotspot_Beta'};
% Plot.Questionnaires = {'KSS', 'Difficult', 'Effortful', 'Focused', 'Motivation', 'Relaxing'};
% Plot.PowerPeaks = {'Hotspot_Amplitude', 'Hotspot_Peak', 'Hotspot_Slope', 'Hotspot_Intercept', 'Hotspot_FWHM' };
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Tasks = Format.Tasks.(Condition);

Condition = 'RRT';

Plot = struct();
Plot.Power = {'Hotspot_Theta', 'Hotspot_Beta'};
Plot.Questionnaires = {'KSS', 'Alertness', 'Anger', 'Difficulty', 'EmotionEnergy', 'Enjoyment', 'Fear', 'FixatingDifficulty', ...
    'Focus', 'Happiness', 'Hunger', 'Mood', 'Motivation', 'Other Pain', 'PhysicEnergy', 'PsychEnergy', 'Relxation', 'Sadness', ...
    'SpiritEnergy', 'Stress', 'Thirst', 'Tolerance', 'WakeDifficulty'};
Plot.PowerPeaks = {'Hotspot_Amplitude', 'Hotspot_Intercept', 'Hotspot_FWHM' };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tasks = {'Fixation'};

TitleTag = strjoin({'Regression', Normalization, Condition}, '_');

SessionLabels = Format.Labels.(Tasks{1}).(Condition).Plot;

Measures = fieldnames(Plot);

Paths.Results = fullfile(Paths.Results, 'Regression');
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

All_Measures_T = table();
Participant_Labels = repmat(Participants, 1, numel(SessionLabels))';

% All_Measures = nan(numel(SessionLabels)*numel(Participants)*numel(Tasks), numel(PlotMeasures));

All_Measures = [];
PlotMeasures = {};

for Indx_M = 1:numel(Measures)
    Measure = Measures{Indx_M};
    Variables = Plot.(Measure);
    
    for Indx_V = 1:numel(Variables)
        Variable = Variables{Indx_V};
        AllTasks = nan(numel(Participants), numel(SessionLabels), numel(Tasks));
        for Indx_T = 1:numel(Tasks)
            T = Tasks{Indx_T};
            Filename = strjoin({Measure, Condition, T, [Variable, '.mat']}, '_');
            load(fullfile(Paths.Stats, Measure, Filename), 'Matrix')
            AllTasks(:, :, Indx_T) = Matrix;
        end
        
        
        switch Normalization
            case 'zscoreS&P'
                ScatterGroup = nan(size(AllTasks));
                for Indx_P = 1:numel(Participants)
                    for Indx_S = 1:numel(SessionLabels)
                        T = AllTasks(Indx_P, Indx_S, :);
                        Mean = nanmean(T(:));
                        STD = nanstd(T(:));
                        AllTasks(Indx_P, Indx_S, :) = (T-Mean)./STD;
                        
                        
                        
                        ScatterGroup(Indx_P, Indx_S, :) = 1:numel(Tasks); % stupid hack, since I cant think right now
                    end
                end
                
                V = AllTasks(:);
                All_Measures = cat(2, All_Measures, V);
                PlotMeasures = cat(2, PlotMeasures, Variable);
                ScatterGroup = ScatterGroup(:); % list of tasks
                
                
                ScatterColors = [];
                
                for Indx_T = 1:numel(Tasks)
                    ScatterColors = cat(1, ScatterColors, Format.Colors.Tasks.(Tasks{Indx_T})) ;
                end
                
            case 'zscoreP'
                
                for Indx_P = 1:numel(Participants)
                    
                    T = AllTasks(Indx_P, :, :);
                    Mean = nanmean(T(:));
                    STD = nanstd(T(:));
                    AllTasks(Indx_P, :, :) = (T-Mean)./STD;
                    
                    
                end
                
                if Indx_M == numel(Measures) && Indx_V == numel(Variables)
                    ScatterGroup = nan(size(AllTasks));
                    for Indx_S = 1:numel(SessionLabels)
                        ScatterGroup(:, Indx_S, :) = Indx_S*ones(numel(Participants), numel(Tasks));
                        
                    end
                    
                    ScatterGroup = ScatterGroup(:); % list of sessions
                end
                
                V = AllTasks(:);
                All_Measures = cat(2, All_Measures, V);
                PlotMeasures = cat(2, PlotMeasures, Variable);
                
                
                ScatterColors = Format.Colors.(Condition).Sessions;
            otherwise
                
                if Indx_M == numel(Measures) && Indx_V == numel(Variables)
                    ScatterGroup = nan(size(AllTasks));
                    for Indx_P = 1:numel(Participants)
                        ScatterGroup(Indx_P, :, :) = Indx_P*ones(numel(SessionLabels), numel(Tasks));
                    end
                    
                    ScatterGroup = ScatterGroup(:); % list of sessions
                end
                ScatterColors = [];
                PlotMeasures = cat(2, PlotMeasures, Variable);
        end
        
        
    end
end

Title = [Condition];

PlotMeasures = replace(PlotMeasures, '_', ' ');

[R,P, CI_Low, CI_Up] = corrcoef( All_Measures, 'Rows','pairwise');
figure('units','normalized','outerposition',[0 0 .4 .7])
PlotCorr(R, [], PlotMeasures, Format)
title([Title, ' R values of all parameters ', Normalization])
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_CorrelateAll_uncorrected.svg']))

figure('units','normalized','outerposition',[0 0 .4 .7])
PlotCorr(R, P, PlotMeasures, Format)
title([Title, ' R values of all parameters, p<.05 corrected ', Normalization])
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_CorrelateAll_Pcorrected.svg']))

figure('units','normalized','outerposition',[0 0 .4 .7])
[~,h] = fdr(P, 0.05);
PlotCorr(R, h, PlotMeasures, Format)
title([Title, ' R values of all parameters, fdr corrected  ', Normalization])
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_CorrelateAll_FDRcorrected.svg']))


AmpIndx = find(strcmpi(PlotMeasures, 'Theta'));
InterIndx = find(strcmpi(PlotMeasures, 'miDuration'));




% PlotGroups = [true, false];
PlotGroups = [true];


for Plotting = PlotGroups
    
    if Plotting
        TitleTagNew = [TitleTag, '_', Normalization, '_PlotGroups'];
        ScatterColorsTemp = ScatterColors;
    else
        TitleTagNew = [TitleTag, '_', Normalization];
        ScatterColorsTemp = 0;
    end
    
    figure('units','normalized','outerposition',[0 0 1 1])
    FigIndx = 1;
    Indx = 1;
    for Indx_X = 1:numel(PlotMeasures)
        for Indx_Y = Indx_X+1:numel(PlotMeasures)
            
            if Indx > 3*5 % loop through subplots until run out, then start new figure
                saveas(gcf,fullfile(Paths.Results, [TitleTagNew, '_ScatterAll', num2str(FigIndx),'.svg']))
                figure('units','normalized','outerposition',[0 0 1 1])
                Indx = 1;
                FigIndx = FigIndx + 1;
            end
            subplot(3, 5, Indx)
            PlotConfetti(All_Measures(:, Indx_X), All_Measures(:, Indx_Y), ...
                ScatterGroup, Format, [], ScatterColorsTemp)
            xlabel(PlotMeasures{Indx_X})
            ylabel(PlotMeasures{Indx_Y})
            title(['R=', num2str(R(Indx_X, Indx_Y), '%.2f'), ' p=', num2str(P(Indx_X, Indx_Y), '%.2f')])
            Indx = Indx+1;
        end
        
    end
    saveas(gcf,fullfile(Paths.Results, [TitleTagNew, '_ScatterAll', num2str(FigIndx), '.svg']))
    
end



AmpIndx = find(strcmpi(PlotMeasures, 'Hotspot Intercept'));
InterIndx = find(strcmpi(PlotMeasures, 'Hotspot Amplitude'));



KSSIndx = find(strcmpi(PlotMeasures, 'KSS'));
ThetaIndx = find(strcmpi(PlotMeasures, 'Hotspot Theta'));


% plot bars of R values for theta amplitude vs theta intercept
figure('units','normalized','outerposition',[0 0 1, .5])
Errors = cat(3, CI_Low(:,  [AmpIndx, InterIndx]), CI_Up(:,  [AmpIndx, InterIndx]));
PlotBars(R(:, [AmpIndx, InterIndx]), Errors, PlotMeasures, cat(1,Format.Colors.Generic.Red, Format.Colors.Generic.Pale3), 'vertical', Format)
y = R(AmpIndx, InterIndx);
y = [y, y];
hold on
x = get(gca, 'xlim');
plot(x, y, ':', 'Color', [.5 .5 .5])
plot(x, -y, ':', 'Color', [.5 .5 .5])
ylim([-1 1])
ylabel('R')
title(['Intercept vs Theta peak Amplitude R values ', Normalization])
legend({'Theta Amplitude', 'Intercept'})
set(gca, 'FontName', Format.FontName, 'FontSize', 13)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_R_PeakAmplitude_v_intercept.svg']))


figure('units','normalized','outerposition',[0 0 1, .5])
subplot(1, 4, 1)
PlotConfetti(All_Measures(:, ThetaIndx), All_Measures(:, KSSIndx), ...
    ScatterGroup, Format, 40, ScatterColorsTemp)
xlabel('Theta')
ylabel('KSS')

title(['Theta and KSS (R=', num2str(R(ThetaIndx, KSSIndx), '%.2f'),...
    ' p=', num2str(P(ThetaIndx, KSSIndx), '%.2f'), ' ', Normalization, ')'])
set(gca, 'FontName', Format.FontName, 'FontSize', 16)


subplot(1, 4, 2)
PlotConfetti(All_Measures(:, AmpIndx), All_Measures(:, KSSIndx), ...
    ScatterGroup, Format, 40, ScatterColorsTemp)
xlabel('Theta Peak Amplitude')
ylabel('KSS')

title(['Theta Peak Amplitude and KSS (R=', num2str(R(AmpIndx, KSSIndx), '%.2f'),...
    ' p=', num2str(P(AmpIndx, KSSIndx), '%.2f'), ' ', Normalization, ')'])
set(gca, 'FontName', Format.FontName, 'FontSize', 16)


subplot(1, 4, 3)
PlotConfetti(All_Measures(:, InterIndx), All_Measures(:, KSSIndx), ...
    ScatterGroup, Format, 40, ScatterColorsTemp)
xlabel('Intercept')
ylabel('KSS')

title(['Intercept and KSS (R=', num2str(R(InterIndx, KSSIndx), '%.2f'),...
    ' p=', num2str(P(InterIndx, KSSIndx), '%.2f'), ' ', Normalization, ')'])
set(gca, 'FontName', Format.FontName, 'FontSize', 16)


FWHMIndx = find(strcmpi(PlotMeasures, 'Hotspot FWHM'));

subplot(1, 4, 4)
PlotConfetti(All_Measures(:, FWHMIndx), All_Measures(:, KSSIndx), ...
    ScatterGroup, Format, 40, ScatterColorsTemp)
xlabel('FWHM')
ylabel('KSS')

title(['FWHM and KSS (R=', num2str(R(FWHMIndx, KSSIndx), '%.2f'),...
    ' p=', num2str(P(FWHMIndx, KSSIndx), '%.2f'), ' ', Normalization, ')'])
set(gca, 'FontName', Format.FontName, 'FontSize', 16)


saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Corr_Theta_v_KSS.svg']))




