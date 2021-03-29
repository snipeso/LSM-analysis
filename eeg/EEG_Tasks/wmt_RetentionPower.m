clear
close all
clc


EEGT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



Normalization = 'zscore'; % 'zscore', TODO: 'BL'
Refresh = false;

Freqs = 1:.25:40;
Subset = 'All'; % 'All', 'Correct', 'Incorrect'
Hotspot = 'Hotspot';
YLim = [-.2 1.4];
Band = 'Theta';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Match2Sample';
Condition = 'BAT';
EEG_Type = 'Wake';
Legend = [ Format.Legend.(Task),'Baseline'];
Colors = [Format.Colors.Match2Sample;Format.Colors.Generic.Dark1];
Window = 4;

EndBL_Trigger = Epochs.(Task).Baseline.Trigger;
StartRT_Trigger = 'S 10'; % start fixatio

Paths.Results = string(fullfile(Paths.Results, 'PowerTasks'));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end


Sessions = Format.Labels.(Task).(Condition).Sessions;
SessionLabels = Format.Labels.(Task).(Condition).Plot;

SummaryFile = fullfile(Paths.Matrices, [Task '_', Normalization, '_', Subset, '_WelchPower.mat']);
if Refresh || ~exist(SummaryFile, 'file')
    
    % get response times
    Responses = [Task, 'AllAnswers.mat'];
    if  ~Refresh &&  exist(fullfile(Paths.Responses, Responses), 'file')
        load(fullfile(Paths.Responses, Responses), 'Answers')
    else
        if ~exist(Paths.Responses, 'dir')
            mkdir(Paths.Responses)
        end
        AllAnswers = importTask(Paths.Datasets, Task, Paths.Responses); % needs to have access to raw data folder
        Answers = cleanupMatch2Sample(AllAnswers);
        
        save(fullfile(Paths.Responses, Responses), 'Answers');
    end
    
    
    Levels = unique(Answers.level);
    
    % assemble matrix: participant x session x condition x ch x freq
    % conditions: n1, n3, n6
    % save BL and encoding matrix participant x session x ch x freq
    Retention = nan(numel(Participants), numel(Sessions), numel(Levels));
    Baseline = Retention;
    Encoding = Retention;
    
    % get eeg data
    for Indx_P = 1:numel(Participants)
        
        % for zscoring
        SUM = zeros(numel(Freqs), 1);
        SUMSQ = zeros(numel(Freqs), 1);
        N = 0;
        
        for Indx_S = 1:numel(Sessions)
            Participant = Participants{Indx_P};
            
            % get subtable
            Trials = Answers(strcmp(Answers.Participant, Participant)& ...
                strcmp(Answers.Session, Sessions{Indx_S}), :);
            
            % load EEG
            EEG_Filename = strjoin({Participant, Task, Sessions{Indx_S}, 'Clean.set'}, '_');
            EEG_Filepath = fullfile(Paths.Preprocessed, 'Interpolated', EEG_Type, Task);
            Cuts_Filepath = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Task);
            if ~exist(fullfile(EEG_Filepath, EEG_Filename), 'file')
                warning(['Cant find ', EEG_Filename])
                continue
            end
            EEG = pop_loadset('filename', EEG_Filename, 'filepath', EEG_Filepath);
            Chanlocs = EEG.chanlocs;
            fs = EEG.srate;
            
            % load cuts, remove noise
            Cuts = fullfile(Cuts_Filepath, [extractBefore(EEG_Filename, '_Clean'), ...
                '_Cleaning_Cuts.mat']);
            EEG = nanNoise(EEG, Cuts);
            
            
            AllTriggerTypes = {EEG.event.type};
            AllTriggerTimes =  [EEG.event.latency];
            EndBaselines =  AllTriggerTimes(strcmp(AllTriggerTypes, EndBL_Trigger));
            StartRetentions =  AllTriggerTimes(strcmp(AllTriggerTypes, StartRT_Trigger));
            
            
            if size(Trials, 1) ~= numel(EndBaselines) || size(Trials, 1) ~= numel(StartRetentions)
                warning(['Something went wrong with triggers for ', EEG_Filename])
                continue
            end
            
            % select only trials that are in specified subset & remove
            % missing responses
            Skipped = Trials.missed;
            switch Subset
                case 'Correct'
                    Remove = not(Trials.response) | Skipped;
                case 'Incorrect'
                    Remove = Trials.response | Skipped;
                otherwise
                    Remove = Skipped;
            end
            
            EndBaselines(Remove) = [];
            StartRetentions(Remove) = [];
            Trials(Remove, :) = [];
            
            % calculate power
            StartBaselines = EndBaselines- round(Window*fs);
            EndRetentions = StartRetentions + round(Window*fs);
            
            R_Power = PowerTrials(EEG, Freqs, StartRetentions, EndRetentions);
            BL_Power = PowerTrials(EEG, Freqs, StartBaselines, EndBaselines);
            E_Power = PowerTrials(EEG, Freqs, EndBaselines, StartRetentions);
            
            % save, split by level
            for Indx_L = 1:numel(Levels)
                T = Trials.level == Levels(Indx_L);
                
                Baseline(Indx_P, Indx_S, Indx_L, 1:numel(Chanlocs), 1:numel(Freqs)) = ...
                    nanmean(BL_Power(T, :, :), 1);
                Encoding(Indx_P, Indx_S, Indx_L, 1:numel(Chanlocs), 1:numel(Freqs)) = ...
                    nanmean(E_Power(T, :, :), 1);
                Retention(Indx_P, Indx_S, Indx_L, 1:numel(Chanlocs), 1:numel(Freqs)) = ...
                    nanmean(R_Power(T, :, :), 1);
            end
            
            All = cat(1, BL_Power, E_Power, R_Power);
            SUM =SUM + squeeze(nansum(nansum(All, 2), 1)); % sum windows and channels
            SUMSQ = SUMSQ + squeeze(nansum(nansum(All.^2, 2), 1));
            N = N + nnz(~isnan(reshape(All(:, :, 1), 1, [])));
            
            
        end
        
        
        if strcmp(Normalization, 'zscore')
            MEAN = SUM./N;
            SD = sqrt((SUMSQ - N.*(MEAN.^2))./(N - 1));
            
            for Indx_S =1:numel(Sessions)
                for Indx_L = 1:numel(Levels)
                    for Indx_C = 1:numel(Chanlocs)
                        BL =  squeeze(Baseline(Indx_P, Indx_S, Indx_L, Indx_C, :))';
                        Baseline(Indx_P, Indx_S, Indx_L, Indx_C, :) = (BL-MEAN')./SD';
                        
                        E = squeeze(Encoding(Indx_P, Indx_S, Indx_L, Indx_C, :))';
                        Encoding(Indx_P, Indx_S, Indx_L, Indx_C, :) = (E-MEAN')./SD';
                        
                        R = squeeze(Retention(Indx_P, Indx_S, Indx_L, Indx_C, :))';
                        Retention(Indx_P, Indx_S, Indx_L, Indx_C, :) = (R-MEAN')./SD';
                    end
                end
            end
        end
        
    end
    save(SummaryFile, 'Retention', 'Baseline', 'Encoding', 'Chanlocs')
else
    load(SummaryFile, 'Retention', 'Baseline', 'Encoding', 'Chanlocs')
end

%%

Levels = 1:3;


TitleInfo = {Task, Normalization,  Subset, Hotspot, Band};
TitleTag = strjoin(TitleInfo, '_'); % TODO!

% plot split by level for each session
figure('units','normalized','outerposition',[0 0 1 .5])
FreqsIndxBand =  dsearchn( Freqs', Bands.(Band)');
Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
for Indx_S = 1:numel(Sessions)
    Matrix = squeeze(nanmean(Retention(:, Indx_S, :, Indexes_Hotspot, :), 4));
    Matrix(:, end+1, :) = squeeze(nanmean(nanmean(Baseline(:, Indx_S, :, Indexes_Hotspot, :), 4), 3));
    
    subplot(1, numel(Sessions), Indx_S)
    PlotPowerHighlight(Matrix, Freqs, FreqsIndxBand, Colors, Format, Legend)
    title([strjoin({'Retention', SessionLabels{Indx_S}, Subset, Hotspot, Band}, ' ')])
    if exist('YLim', 'var')
        ylim(YLim)
    end
    xlim([0 30])
end
NewLims = SetLims(1, 3, 'y');

saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_Retention_Power_by_Level.svg']))

% Plot power during encoding
figure('units','normalized','outerposition',[0 0 1 .5])
FreqsIndxBand =  dsearchn( Freqs', Bands.(Band)');
Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
for Indx_S = 1:numel(Sessions)
    Matrix = squeeze(nanmean(Encoding(:, Indx_S, :, Indexes_Hotspot, :), 4));
    Matrix(:, end+1, :) = squeeze(nanmean(nanmean(Baseline(:, Indx_S, :, Indexes_Hotspot, :), 4), 3));
    
    subplot(1, numel(Sessions), Indx_S)
    PlotPowerHighlight(Matrix, Freqs, FreqsIndxBand, Colors, Format, Legend)
    title([strjoin({'Encoding', SessionLabels{Indx_S}, Task, Normalization}, ' ')])
    if exist('YLim', 'var')
        ylim(YLim)
    end
    xlim([0 30])
end
NewLims = SetLims(1, 3, 'y');
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Encoding_Power_by_Level.svg']))


% plot topography

figure('units','normalized','outerposition',[0 0 .5 .5])
Indx = 1;
for Indx_L = 1:numel(Levels)
    for Indx_S = 1:numel(Sessions)
        BL =  squeeze(nanmean(nanmean(Baseline(:, Indx_S, :, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5),3));
        M = squeeze(nanmean(Retention(:, Indx_S, Indx_L, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
        subplot(numel(Levels), numel(Sessions), Indx)
        PlotTopoDiff(BL, M, Chanlocs, [-5 5], Format)
        title(['R ', SessionLabels{Indx_S}, ' ', Format.Legend.Match2Sample{Indx_L}])
        Indx = Indx+1;
    end
end

saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Retention_Topos_by_Level.svg']))


figure('units','normalized','outerposition',[0 0 .5 .5])
Indx = 1;
for Indx_L = 1:numel(Levels)
    for Indx_S = 1:numel(Sessions)
        BL =  squeeze(nanmean(nanmean(Baseline(:, Indx_S, :, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5),3));
        M = squeeze(nanmean(Encoding(:, Indx_S, Indx_L, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
        subplot(numel(Levels), numel(Sessions), Indx)
        PlotTopoDiff(BL, M, Chanlocs, [-5 5], Format)
        title(['E ', SessionLabels{Indx_S}, ' ', Format.Legend.Match2Sample{Indx_L}])
        Indx = Indx+1;
    end
end

saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Encoding_Topos_by_Level.svg']))
% TODO: BL, normalizes trial by baseline just prior


%%% plot SD effect for BL, Encoding and retention
figure
Indx = 1;
for Indx_L = 1:numel(Levels)
    for Indx_S = 2:numel(Sessions)
        BL =  squeeze(nanmean(Baseline(:, 1, Indx_L, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
        M = squeeze(nanmean(Baseline(:, Indx_S, Indx_L, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
        
        subplot(numel(Levels), numel(Sessions)-1, Indx)
        PlotTopoDiff(BL, M, Chanlocs, [-5 5], Format)
        title(['SD effect on BL ', SessionLabels{Indx_S}, ' ', Format.Legend.Match2Sample{Indx_L}])
        Indx = Indx+1;
    end
end

saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Baseline_Topos_by_Session.svg']))



figure
Indx = 1;
for Indx_L = 1:numel(Levels)
    for Indx_S = 2:numel(Sessions)
        BL =  squeeze(nanmean(Retention(:, 1, Indx_L, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
        M = squeeze(nanmean(Retention(:, Indx_S, Indx_L, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
        
        subplot(numel(Levels), numel(Sessions)-1, Indx)
        PlotTopoDiff(BL, M, Chanlocs, [-5 5], Format)
        title(['SD effect on RT ', SessionLabels{Indx_S}, ' ', Format.Legend.Match2Sample{Indx_L}])
        Indx = Indx+1;
    end
end

saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Retention_Topos_by_Session.svg']))



figure
Indx = 1;
for Indx_L = 1:numel(Levels)
    for Indx_S = 2:numel(Sessions)
        BL =  squeeze(nanmean(Encoding(:, 1, Indx_L, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
        M = squeeze(nanmean(Encoding(:, Indx_S, Indx_L, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
        
        subplot(numel(Levels), numel(Sessions)-1, Indx)
        PlotTopoDiff(BL, M, Chanlocs, [-5 5], Format)
        title(['SD effect on EN ', SessionLabels{Indx_S}, ' ', Format.Legend.Match2Sample{Indx_L}])
        Indx = Indx+1;
    end
end

saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Encoding_Topos_by_Session.svg']))


%%% N1 vs N3

figure('units','normalized','outerposition',[0 0 .5 .3])
Indx = 1;

for Indx_S = 1:numel(Sessions)
    BL =  squeeze(nanmean(Encoding(:, Indx_S, 1, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
    M = squeeze(nanmean(Encoding(:, Indx_S, 2, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
    subplot(1, numel(Sessions), Indx)
    PlotTopoDiff(BL, M, Chanlocs, [-5 5], Format)
    title(['R ', SessionLabels{Indx_S}, ' N1 vs N3'])
    Indx = Indx+1;
end

saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Retention_Topos_N1vsN3.svg']))


%%% plot for each participant
Session = 3;
figure('units','normalized','outerposition',[0 0 1 1])
for Indx_P = 1:numel(Participants)
    BL =  squeeze(nanmean(Retention(Indx_P, Session, 1, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
    M = squeeze(nanmean(Retention(Indx_P, Session, 2, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
    subplot(3, 4, Indx_P)
    topoplot(M-BL, Chanlocs,  'style', 'map', 'headrad', 'rim','gridscale', 150)
    colormap(Format.Colormap.Divergent)
    colorbar
    title([Participants{Indx_P}, ' N1 vs N3'])
end
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Individuals_', Sessions{Session}, '_N1vsN3.svg']))


% Level = 1;
% figure('units','normalized','outerposition',[0 0 1 1])
% for Indx_P = 1:numel(Participants)
%     BL =  squeeze(nanmean(Retention(Indx_P, 1, Level, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
%     M = squeeze(nanmean(Retention(Indx_P, 3, Level, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
%     subplot(3, 4, Indx_P)
%    topoplot(M-BL, Chanlocs,  'style', 'map', 'headrad', 'rim','gridscale', 150)
%    colormap(Format.Colormap.Divergent)
%    colorbar
%     title([Participants{Indx_P}, ' N1 vs N3'])
% end
% saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Individuals_', Levels{Level}, '_S1vsS3.svg']))
%
%


% plot split by level for each session
figure('units','normalized','outerposition',[0 0 .5 .5])
FreqsIndxBand =  dsearchn( Freqs', Bands.(Band)');
Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
for Indx_S = 1:numel(Sessions)
    Matrix = squeeze(nanmean(Retention(:, Indx_S, 1:2, Indexes_Hotspot, :), 4));
    
    subplot(1, numel(Sessions), Indx_S)
    PlotPowerHighlight(Matrix, Freqs, FreqsIndxBand, Colors, Format, Legend(1:2))
    title([strjoin({'Retention', SessionLabels{Indx_S}, Task, Normalization}, ' ')])
    xlim([0 30])
end
NewLims = SetLims(1, 3, 'y');

saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Retention_Power_N1vsN3.svg']))




%%% correlate increase with SD with increase with WM

WM = squeeze(nanmean(nanmean(Retention(:, 1, 1:2, Indexes_Hotspot, ....
    FreqsIndxBand), 4),5));
SD =  squeeze(nanmean(nanmean(nanmean(Baseline(:, [1,3], :, Indexes_Hotspot, ....
    FreqsIndxBand), 4),5),3));

% WM(10, :) = nan;
% SD(10, :) = nan;
% WMd = (WM(:,2)-WM(:, 1))./WM(:,1);
% SDd = (SD(:,2)-SD(:, 1))./SD(:,1);
WMd = (WM(:,2)-WM(:, 1));
SDd = (SD(:,2)-SD(:, 1));


figure
PlotParticipantConfetti(WMd, SDd, Format, 50)
xlabel('Increase WM (%)')
ylabel('Increase SD (%)')
[r, p] =  corr(WMd, SDd, 'rows', 'complete');
title(['r=', num2str(r), '; p=', num2str(p)])
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_IndividualsIncrease.svg']))



% SD2 peak vs N3 peak
WM = squeeze(nanmean(Retention(:, 1, 1:2, Indexes_Hotspot, :), 4));
SD = squeeze(nanmean(nanmean(Baseline(:, [1,3], :, Indexes_Hotspot, :), 4),3));

Matrix = cat(2, WM(:, 2, :), SD(:, 2, :));
figure
PeakComparison(Matrix, Bands.(Band), Freqs, {'N3', 'SD2'}, Format)
title(strjoin([TitleInfo, ' Retention N3 peak vs SD2 peak'],  ' '))
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Retention_PeakChange_N3vsSD2.svg']))


% same but for encoding
WM = squeeze(nanmean(Encoding(:, 1, 1:2, Indexes_Hotspot, :), 4));
SD = squeeze(nanmean(nanmean(Baseline(:, [1,3], :, Indexes_Hotspot, :), 4),3));

Matrix = cat(2, WM(:, 2, :), SD(:, 2, :));
figure
PeakComparison(Matrix, Bands.(Band), Freqs, {'N3', 'SD2'}, Format)
title(strjoin([TitleInfo, ' Encoding N3 peak vs SD2 peak'],  ' '))
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Encoding_PeakChange_N3vsSD2.svg']))



% BLvsSD2 peak vs N1vsN3peak
WM = squeeze(nanmean(Retention(:, 1, 1:2, Indexes_Hotspot, :), 4));
SD = squeeze(nanmean(nanmean(Baseline(:, [1,3], :, Indexes_Hotspot, :), 4),3));

WMd = WM(:, 2, :)- WM(:, 1, :);
SDd = SD(:, 2, :)- SD(:, 1, :);
Matrix = cat(2, WMd(:, 1, :), SDd(:, 1, :));
figure
PeakComparison(Matrix, Bands.(Band), Freqs, {'N1vN3', 'BLvSD2'}, Format)
title(strjoin([TitleInfo, 'Change with WM vs SD'],  ' '))
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Retention_PeakChange_N1vN3_BLvSD2.svg']))

%%
%%% spectrum and peaks at different locations
PlotCh = 'Sample';

EEG_Channels.(PlotCh) = sort(EEG_Channels.(PlotCh));
Indexes =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(PlotCh));
ChColors = Format.Colormap.Rainbow(round(linspace(1, size(Format.Colormap.Rainbow, 1), nnz(Indexes)+1)), :);
WM = squeeze(Retention(:, 1, 1:2, Indexes, :));
SD = squeeze(nanmean(Baseline(:, [1,3], :, Indexes, :), 3));
WMd = squeeze(WM(:, 2, :, :)- WM(:, 1, :, :));
SDd = squeeze(SD(:, 2, :, :)- SD(:, 1, :, :));

figure('units','normalized','outerposition',[0 0 .5 .5])

% WM peak change
subplot(2, 2, 1)
PeakComparison(WMd, Bands.(Band), Freqs, string(EEG_Channels.(PlotCh)), Format)
title(strjoin({Band, Normalization, 'Peak shift WM', PlotCh},  ' '))

% WM whole spectrum change
subplot(2, 2, 2)
PlotPowerHighlight(WMd, Freqs, FreqsIndxBand, ChColors, Format, string(EEG_Channels.(PlotCh)))
title(strjoin({Band, Normalization, 'Spectrum shift WM', PlotCh},  ' '))
xlim([0 30])

% SD peak change
subplot(2, 2, 3)
PeakComparison(SDd, Bands.(Band), Freqs, string(EEG_Channels.(PlotCh)), Format)
title(strjoin({Band, Normalization, 'Peak shift SD', PlotCh},  ' '))

% WM whole spectrum change
subplot(2, 2, 4)
PlotPowerHighlight(SDd, Freqs, FreqsIndxBand, ChColors, Format, string(EEG_Channels.(PlotCh)))
title(strjoin({Band, Normalization, 'Spectrum shift SD', PlotCh},  ' '))
xlim([0 30])


Title =  strjoin({Task, Normalization, Subset, PlotCh,  Band, 'Channel_Shift.svg'}, '_');
saveas(gcf,fullfile(Paths.Results, Title))

%%
%%% hedges g
WM = squeeze(nanmean(nanmean(Retention(:, 1, 1:2, Indexes_Hotspot, ....
    FreqsIndxBand), 4),5));
SD =  squeeze(nanmean(nanmean(nanmean(Baseline(:, [1,3], :, Indexes_Hotspot, ....
    FreqsIndxBand), 4),5),3));

[WMg, WMCI] = HedgesG(squeeze(WM(:, 2)),squeeze(WM(:, 1)));
[SDg, SDCI] = HedgesG(squeeze(SD(:, 2)),squeeze(SD(:, 1)));

figure
C = [Format.Colors.Generic.Dark1; Format.Colors.Generic.Red];

PlotBars2([WMg, SDg], [WMCI, SDCI]', {'WM', 'SD'}, C, 'vertical', Format)
set(gca, 'FontSize', 14)

