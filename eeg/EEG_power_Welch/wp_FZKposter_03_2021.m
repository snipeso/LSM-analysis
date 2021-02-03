
clear
clc
close all


wp_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% set parameters

Scaling = 'zscore'; % 'zscore', 'log', 'none'
YLimBand = [-2, 6 ];
YLimSpectrum = [-.5, 1.2];

Refresh = false;
Tasks = {'LAT', 'PVT', 'Match2Sample', 'SpFT', 'Game', 'Music'};
TasksLabels = {'LAT', 'PVT', 'WMT', 'Speech', 'Game', 'Music'};


RRT = { 'Oddball', 'Fixation',  'Standing'};
RRTLabels = RRT;
BandLabel = 'theta';
Hotspot = 'Hotspot'; % TODO: make sure this is in apporpriate figure name
TitleTag = ['FZK_', BandLabel, '_', Scaling];
Plot_Single_Topos = true;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Channels_10_20 = EEG_Channels.Standard;

Sessions_Tasks_Title = 'Basic';
Sessions_RRT_Title = 'RRT';
CompareTaskSessions = {'Baseline', 'Session2'};


Paths.Results = fullfile(Paths.Results, 'FZK_03-2021');
Paths.Results = string(Paths.Results);
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end


Results = struct();

switch Scaling
    case 'log'
        YLabel = 'Log Power Density';
    case 'none'
        YLabel = 'Power Density';
    case 'zscore'
        YLabel = 'Power Density (z scored)';
end

% load all tasks (optional z-scored or not, so have both raw theta values
% and z-scored for stats)

% load power data
Sessions_Tasks = allSessions.(Sessions_Tasks_Title);
SessionLabels_Tasks = allSessionLabels.(Sessions_Tasks_Title);
Sessions_RRT = allSessions.(Sessions_RRT_Title);
SessionLabels_RRT = allSessionLabels.(Sessions_RRT_Title);

if strcmp(Scaling, 'zscore')
    [PowerStructTasks, Chanlocs, ~] = LoadWelchData(Paths, Tasks, Sessions_Tasks, Participants, 'none');
    [PowerStructRRT, ~, ~] = LoadWelchData(Paths, RRT, Sessions_RRT, Participants, 'none');
    Pre  = {PowerStructTasks, PowerStructRRT};
    PowerStructListZScored = ZScoreFFTList(Pre, Freqs);
    PowerStructTasks = PowerStructListZScored{1};
    PowerStructRRT = PowerStructListZScored{2};
    
else
    [PowerStructTasks, Chanlocs, Quantiles] = LoadWelchData(Paths, Tasks, Sessions_Tasks, Participants, Scaling);
    [PowerStructRRT, ~, ~] = LoadWelchData(Paths, RRT, Sessions_RRT, Participants, Scaling);
end

%%

AllTasks = [Tasks, RRT];
AllTasksLabels = [TasksLabels, RRTLabels];
nParticipants = numel(Participants);
nSessions_Tasks = numel(Sessions_Tasks);
nSessions_RRT = numel(Sessions_RRT);
nTasks = numel(Tasks);
nRRT = numel(RRT);
nAllTasks = numel(AllTasks);
nChannels = numel(Chanlocs);
nFreqs = numel(Freqs);
n10_20 = numel(Channels_10_20);
FreqsIndxBand =  dsearchn( Freqs', Bands.(BandLabel)');
Indexes_10_20 =  ismember( str2double({Chanlocs.labels}), Channels_10_20); % TODO: make sure in order!


ChannelLabels = {Chanlocs.labels}; % TEMP! Problem is getting the actual string labels
ChannelLabels = ChannelLabels(Indexes_10_20);

Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gather data

% FZ, CZ, PZ, OZ (eventually do 10-20 grid) theta across sessions
Band_10_20_Tasks = nan(nParticipants, nSessions_Tasks, nTasks, n10_20);
Band_10_20_RRT = nan(nParticipants, nSessions_RRT, nRRT, n10_20);

% BL + SD2 topography
Band_Topo_Tasks = nan(nParticipants, nChannels, nSessions_Tasks, nTasks);
Band_Topo_RRT = nan(nParticipants, nChannels, nSessions_RRT, nRRT);

% BL + SD2 spectrums of frontal cluster (+ occipital cluster for
% comparison); special averaging of R7 and R8 for RRT
Hotspot_Spectrum = nan(nParticipants, nFreqs, 2, nAllTasks);
Hotspot_Spectrum_Raw = nan(nParticipants, nFreqs, 2, nAllTasks);


% from above, get theta range, and calculate effect size
Band_Hotspot = nan(nParticipants, 2, nAllTasks);


%%% assign data to matrices
for Indx_P = 1:nParticipants
    Indx_AllT = 1;
    for Indx_T = 1:nTasks
        for Indx_ST = 1:nSessions_Tasks
            
            FFT =   PowerStructTasks(Indx_P).(Tasks{Indx_T}).(Sessions_Tasks{Indx_ST});
            if isempty(FFT)
                continue
            end
            
            
            % get hotspot spectrum
            if  any(ismember(CompareTaskSessions, Sessions_Tasks{Indx_ST}))
                Hotspot_Spectrum(Indx_P, :, ismember(CompareTaskSessions, Sessions_Tasks{Indx_ST}), Indx_AllT) = ...
                    nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 1),3);
            end
            
            % get power of band
            FFT = FFT(:, FreqsIndxBand(1):FreqsIndxBand(2), :);
            Band = nansum(nanmean(FFT, 3), 2).*FreqRes;
            
            Band_Topo_Tasks(Indx_P, :, Indx_ST, Indx_T) = Band;
            Band_10_20_Tasks(Indx_P, Indx_ST, Indx_T, :) = squeeze(Band(Indexes_10_20));
            
            Band_Hotspot(Indx_P, ismember(CompareTaskSessions, Sessions_Tasks{Indx_ST}), Indx_AllT) = ...
                squeeze(nanmean(Band(Indexes_Hotspot)));
        end
        Indx_AllT = Indx_AllT + 1;
    end
    
    % Same for RRT
    for Indx_T = 1:nRRT
        ReplaceBL = false;
        EmergencyBL_Spectrum = [];
        EmergencyBL_Band = []; % TEMP!
        for Indx_SR = 1:nSessions_RRT
            
            FFT = PowerStructRRT(Indx_P).(RRT{Indx_T}).(Sessions_RRT{Indx_SR});
            if isempty(FFT)
                
                if strcmp(Sessions_RRT{Indx_SR}, 'BaselinePost') % in emergency, use mainpost as bl
                    warning(['Missing baseline for ', Participants{Indx_P}, ' ', RRT{Indx_T}, ', Using MainPost'])
                    ReplaceBL = true;
                end
                
                continue
            end
            
            
            % get theta power
            meanFFT = FFT(:, FreqsIndxBand(1):FreqsIndxBand(2), :);
            Band = nansum(nanmean(meanFFT, 3), 2).*FreqRes;
            
            Band_Topo_RRT(Indx_P, :, Indx_SR, Indx_T) = Band;
            Band_10_20_RRT(Indx_P, Indx_SR, Indx_T, :) = squeeze(Band(Indexes_10_20));
            
            
            % get hotspot spectrum, averaging Main7&8
            if  strcmp(Sessions_RRT{Indx_SR}, 'BaselinePost')
                Hotspot_Spectrum(Indx_P, :, 1, Indx_AllT) = nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 1),3);
                Band_Hotspot(Indx_P, 1, Indx_AllT) = squeeze(nanmean(Band(Indexes_Hotspot)));
                
            elseif strcmp(Sessions_RRT{Indx_SR}, 'MainPost')
                EmergencyBL_Spectrum = nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 1),3);
                EmergencyBL_Band = squeeze(nanmean(Band(Indexes_Hotspot)));
            elseif strcmp(Sessions_RRT{Indx_SR}, 'Main7') || strcmp(Sessions_RRT{Indx_SR}, 'Main8') % TODO: write more succintly
                
                SD = cat(3, squeeze(Hotspot_Spectrum(Indx_P, :, 2, Indx_AllT)), ...
                    squeeze(nanmean(nanmean(FFT(Indexes_Hotspot, :, :), 1),3)));
                
                Hotspot_Spectrum(Indx_P, :, 2, Indx_AllT) =  nanmean(SD, 3);
                
                SDBand = [squeeze( Band_Hotspot(Indx_P, 2, Indx_AllT)), squeeze(nanmean(Band(Indexes_Hotspot)))];
                Band_Hotspot(Indx_P, 2, Indx_AllT) = nanmean(SDBand);
            end
            
        end
        
        
        if ReplaceBL
            Hotspot_Spectrum(Indx_P, :, 1, Indx_AllT) =  EmergencyBL_Spectrum;
            Band_Hotspot(Indx_P, 1, Indx_AllT) =  EmergencyBL_Band;
        end
        
        Indx_AllT = Indx_AllT + 1;
        
        
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots & Stats
Colors = [];

for Indx_T = 1:nAllTasks
    Colors = cat(1, Colors, Format.Colors.Tasks.(AllTasks{Indx_T})) ;
end


%%% Plot single channels

% plot tasks
% TODO: make multiple comparisons across RRT and tasks?
for Indx_Ch = 1:n10_20
    figure('units','normalized','outerposition',[0 0 .2 .4])
    PlotSpaghettiOs(squeeze(Band_10_20_Tasks(:, :, :, Indx_Ch)), 1,  Sessions_Tasks, Tasks, Colors, Format)
    title([ChannelLabels{Indx_Ch}, ' ', BandLabel])
    ylim(YLimBand)
    if Indx_Ch > 1
        legend off
    end
    
    saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_Tasks_',ChannelLabels{Indx_Ch}, '.svg']))
end

% plot RRT
for Indx_Ch = 1:n10_20
    figure('units','normalized','outerposition',[0 0 .5 .4])
    PlotSpaghettiOs(squeeze(Band_10_20_RRT(:, :, :, Indx_Ch)), 2,  Sessions_RRT, RRT, Colors(end-2:end, :), Format)
    title([ChannelLabels{Indx_Ch}, ' ', BandLabel])
    ylim(YLimBand)
    if Indx_Ch > 1
        legend off
    end
    
    saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_RRT_',ChannelLabels{Indx_Ch}, '.svg']))
end


%%% plot topographies
CLims = [-5 5];


% plot tasks as change from BL of S1 and S2
figure('units','normalized','outerposition',[0 0 1 .4])
Indx = 1;
for Indx_ST = 2:3
    for Indx_T = 1:nTasks
        subplot(2, nTasks, Indx)
        M1 = squeeze(Band_Topo_Tasks(:, :, 1, Indx_T)); % baseline session
        M2 = squeeze(Band_Topo_Tasks(:, :, Indx_ST, Indx_T));
        PlotTopoDiff(M1, M2, Chanlocs, CLims, Format)
        title([TasksLabels{Indx_T}, ' ', Sessions_Tasks{Indx_ST}])
        
        Indx = Indx+1;
    end
end
saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_TasksTopos.svg']))


% plot RRT as change from BL for all sessions
figure('units','normalized','outerposition',[0 0 1 1])
Indx = 1;
for Indx_T = 1:nRRT
    for Indx_SR = [1, 3:nSessions_RRT]
        subplot(nRRT, nSessions_RRT-1, Indx)
        M1 = squeeze(Band_Topo_RRT(:, :, 2, Indx_T)); % baseline session
        M2 = squeeze(Band_Topo_RRT(:, :, Indx_SR, Indx_T));
        PlotTopoDiff(M1, M2, Chanlocs, CLims, Format)
        colorbar off
        title([RRTLabels{Indx_T}, ' ', Sessions_RRT{Indx_SR}])
        
        Indx = Indx+1;
    end
end
saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_RRTTopos.svg']))




Scale = 500;
Low = -2;
if Plot_Single_Topos
    
    % plot individual tasks
    Destination = fullfile(Paths.Results, 'Simple Topo');
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    for Indx_S = 1:2
        for Indx_T = 1:nTasks
            figure('units','normalized','outerposition',[0 0 .2 .4])
            M = squeeze(nanmean(Band_Topo_Tasks(:, :, Indx_S, Indx_T), 1)); %  session
            
            topoplot(M, Chanlocs, 'maplimits', [Low, CLims(2)], 'style', 'map', 'headrad', 'rim', ...
                'gridscale', Scale)
            colormap(Format.Colormap.Linear)
            
            saveas(gcf,fullfile(Destination, [TitleTag, '_', CompareTaskSessions{Indx_S}, '_Topo_Tasks_', ...
                num2str(Low),'_', num2str(CLims(2)), '_' Tasks{Indx_T}, '.svg']))
        end
        
        
        % plot RRT as difference from baseline of M7/M8
        for Indx_R = 1:nRRT
            figure('units','normalized','outerposition',[0 0 .2 .4])
            
            M = squeeze(nanmean(Band_Topo_RRT(:, :, Indx_S, Indx_R), 1)); % session
            if Indx_S == 2
                SD_Indx = ismember(Sessions_RRT, {'Main7', 'Main8'});
                M = squeeze(nanmean(nanmean(Band_Topo_RRT(:, :, SD_Indx, Indx_R), 3), 1));
            end
            topoplot(M, Chanlocs, 'maplimits', [Low, CLims(2)], 'style', 'map', 'headrad', 'rim', ...
                'gridscale', Scale)
            colormap(Format.Colormap.Linear)
            
            saveas(gcf,fullfile(Destination, [TitleTag, '_', CompareTaskSessions{Indx_S}, '_Topo_RRT_', ...
                num2str(Low), '_', num2str(CLims(2)), '_' RRT{Indx_R}, '.svg']))
        end
    end
    
    
    % save colorbar separatesly
    figure
    h = colorbar;
    colormap(Format.Colormap.Linear)
    caxis([Low, CLims(2)])
    set(gca, 'FontName', Format.FontName, 'FontSize', 22)
    ylabel(h, 'z scores', 'FontSize', 30)
    axis off
    saveas(gcf,fullfile(Destination, [TitleTag, '_Topo_RRT_', ...
        num2str(Low), '_', num2str(CLims(2)), '_Colorbar.svg']))
    
    
    
    %%%%%%%%%%%%%%%%%%%%%
    
    % plot individual tasks differences
    Destination = fullfile(Paths.Results, 'SD2 vs BL');
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    for Indx_T = 1:nTasks
        figure('units','normalized','outerposition',[0 0 .2 .4])
        M1 = squeeze(Band_Topo_Tasks(:, :, 1, Indx_T)); % baseline session
        M2 = squeeze(Band_Topo_Tasks(:, :, end, Indx_T));
        PlotTopoDiff(M1, M2, Chanlocs, CLims, Format)
        colorbar off
        saveas(gcf,fullfile(Destination, [TitleTag, '_SD2-BL_Topo_Tasks_', ...
            num2str(CLims(1)), '_', num2str(CLims(2)), '_' Tasks{Indx_T}, '.svg']))
    end
    
    
    % plot RRT as difference from baseline of M7/M8
    for Indx_R = 1:nRRT
        figure('units','normalized','outerposition',[0 0 .2 .4])
        
        M1 = squeeze(Band_Topo_RRT(:, :, 1, Indx_R)); % baseline session
        SD_Indx = ismember(Sessions_RRT, {'Main7', 'Main8'});
        M2 = squeeze(nanmean(Band_Topo_RRT(:, :, SD_Indx, Indx_R), 3));
        PlotTopoDiff(M1, M2, Chanlocs, CLims, Format)
        colorbar off
        saveas(gcf,fullfile(Destination, [TitleTag, '_SD2-BL_Topo_RRT_', ...
            num2str(CLims(1)), '_', num2str(CLims(2)), '_' RRT{Indx_R}, '.svg']))
    end
end

% save colorbar separatesly
figure
h = colorbar;
colormap(Format.Colormap.Divergent)
caxis([CLims])
set(gca, 'FontName', Format.FontName, 'FontSize', 22)
ylabel(h, 't values', 'FontSize', 30)
axis off
saveas(gcf,fullfile(Destination, [TitleTag, '_TaskTopos_Colorbar.svg']))


%%% plot subjects S2 hotspot
for Indx_T = 1:nAllTasks
    figure('units','normalized','outerposition',[0 0 .5 .8])
    
    for Indx_S = 1:2
        subplot(2, 1, Indx_S)
        hold on
        for Indx_P = 1:nParticipants
            
            C = [Format.Colors.DarkParticipants(Indx_P, :), .5];
            P_SD = squeeze(Hotspot_Spectrum(Indx_P, :, Indx_S, Indx_T));
            plot(Freqs, P_SD, 'Color',C, 'LineWidth', 3)
            
        end
        
        xlabel('Frequency (Hz)')
        ylabel(YLabel)
        ylim([min(Hotspot_Spectrum, [], 'all'), max(Hotspot_Spectrum, [], 'all')])
        set(gca, 'FontName', Format.FontName, 'FontSize', 14)
        
        title([AllTasksLabels{Indx_T}, ' ', CompareTaskSessions{Indx_S}])
    end
    saveas(gcf,fullfile(Paths.Results, [TitleTag, AllTasks{Indx_T}, '_Participants.svg']))
    
end



%%% Plot change in spectrum from BL to SD2 for hotspot
for Indx_T = 1:nAllTasks
    C = Format.Colors.Tasks.(AllTasks{Indx_T});
    S_BL = squeeze(Hotspot_Spectrum(:, :, 1, Indx_T));
    S_SD = squeeze(Hotspot_Spectrum(:, :, 2, Indx_T));
    
    figure('units','normalized','outerposition',[0 0 .25 .4])
    hold on
    plot(Freqs, zeros(size(Freqs)), ':', 'LineWidth', .1, 'Color', 'k')
    % plot baseline
    plot(Freqs, nanmean(S_BL, 1), 'LineWidth', 1.5, 'Color', [.6 .6 .6])
    plot(Freqs(FreqsIndxBand(1):FreqsIndxBand(2)), ...
        nanmean(S_BL(:, FreqsIndxBand(1):FreqsIndxBand(2)), 1), ...
        'Color',C, 'LineWidth', 4)
    
    % plot main
    plot(Freqs, nanmean(S_SD, 1), 'LineWidth', 1.5, 'Color', [0 0 0])
    plot(Freqs(FreqsIndxBand(1):FreqsIndxBand(2)), ...
        nanmean(S_SD(:, FreqsIndxBand(1):FreqsIndxBand(2)), 1), ...
        'Color',C, 'LineWidth', 4)
    TimeSeriesStats(cat(3, S_BL, S_SD), Freqs, 100);
    clc
    ylim(YLimSpectrum)
    xlim([1 25])
    ylabel(YLabel)
    
    set(gca, 'FontName', Format.FontName, 'FontSize', 12)
    xlabel('Frequency (Hz)',  'FontSize', 14)
    %     title(AllTasksLabels{Indx_T}, 'FontSize', 20)
    %     axis square
    
    saveas(gcf,fullfile(Paths.Results, [TitleTag, '_SD2-BL_Freqs_', ...
        AllTasks{Indx_T}, '.svg']))
    
end






%%% Effect Sizes
BL_SD_Hotspot = struct();
for Indx_T = 1:nAllTasks
    BL = squeeze(Band_Hotspot(:, 1, Indx_T));
    SD2 = squeeze(Band_Hotspot(:, 2, Indx_T));
    statsHedges = mes( SD2, BL, 'hedgesg', 'isDep', 1, 'nBoot', 1000);
    BL_SD_Hotspot(Indx_T).task = AllTasks{Indx_T};
    BL_SD_Hotspot(Indx_T).mean = nanmean(Band_Hotspot(:, :, Indx_T),'all');
    BL_SD_Hotspot(Indx_T).p = statsHedges.t.p;
    BL_SD_Hotspot(Indx_T).HedgesG = statsHedges.hedgesg;
    BL_SD_Hotspot(Indx_T).HedgesCI_Low = statsHedges.hedgesgCi(1);
    BL_SD_Hotspot(Indx_T).HedgesCI_High = statsHedges.hedgesgCi(2);
    
    % TODO: normality tests?
    
end


BL_SD_Hotspot = struct2table(BL_SD_Hotspot);
BL_SD_Hotspot.fdr_p = fdr(BL_SD_Hotspot.p);

writetable(BL_SD_Hotspot, fullfile(Paths.Results, [TitleTag, '_', Hotspot,'_EffectSizes.csv']));

% correct for multiple comparisons

figure('units','normalized','outerposition',[0 0 .5 .5])
PlotBars(BL_SD_Hotspot.HedgesG, [BL_SD_Hotspot.HedgesCI_Low,BL_SD_Hotspot.HedgesCI_High ], AllTasksLabels, Colors, 'vertical', Format)
ylabel('Hedges g')
set(gca, 'FontSize', 12)
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_SD2-BL_EffectSizes.svg']))
