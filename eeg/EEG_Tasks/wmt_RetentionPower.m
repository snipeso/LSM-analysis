

clear
close all
clc


EEGT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



Normalization = 'zscore'; % 'zscore', TODO: 'BL'
Refresh = true;

Freqs = 1:.25:40;
Subset = 'Incorrect'; % 'All', 'Correct', 'Incorrect'
Hotspot = 'Hotspot';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Match2Sample';
Condition = 'BAT';
EEG_Type = 'Wake';
Legend = [ Format.Legend.(Task),'Baseline'];
Colors = [Format.Colors.Match2Sample;Format.Colors.Generic.Dark1];
Window = 4;

EndBL_Trigger = 'S  3';
StartRT_Trigger = 'S 10';

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
else
    load(SummaryFile, 'Retention', 'Baseline', 'Encoding', 'Chanlocs')
end

%%

% plot split by level for each session
figure('units','normalized','outerposition',[0 0 1 1])
FreqsIndxBand =  dsearchn( Freqs', Bands.Theta');
Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
for Indx_S = 1:numel(Sessions)
    Matrix = squeeze(nanmean(Retention(:, Indx_S, :, Indexes_Hotspot, :), 4));
    Matrix(:, end+1, :) = squeeze(nanmean(nanmean(Baseline(:, Indx_S, :, Indexes_Hotspot, :), 4), 3));
    
    subplot(1, numel(Sessions), Indx_S)
    PlotPowerHighlight(Matrix, Freqs, FreqsIndxBand, Colors, Format, Legend)
    title([strjoin({'Retention', SessionLabels{Indx_S}, Task, Normalization}, ' ')])
end
NewLims = SetLims(1, 3, 'y');

saveas(gcf,fullfile(Paths.Results, [ Task, '_', Normalization, ...
    '_', Subset, '_Retention_Power_by_Level.svg']))

% Plot power during encoding
figure('units','normalized','outerposition',[0 0 1 1])
FreqsIndxBand =  dsearchn( Freqs', Bands.Theta');
Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
for Indx_S = 1:numel(Sessions)
    Matrix = squeeze(nanmean(Encoding(:, Indx_S, :, Indexes_Hotspot, :), 4));
    Matrix(:, end+1, :) = squeeze(nanmean(nanmean(Baseline(:, Indx_S, :, Indexes_Hotspot, :), 4), 3));
    
    subplot(1, numel(Sessions), Indx_S)
    PlotPowerHighlight(Matrix, Freqs, FreqsIndxBand, Colors, Format, Legend)
    title([strjoin({'Encoding', SessionLabels{Indx_S}, Task, Normalization}, ' ')])
end
NewLims = SetLims(1, 3, 'y');
saveas(gcf,fullfile(Paths.Results, [ Task, '_', Normalization, ...
    '_', Subset, '_Encoding_Power_by_Level.svg']))

%%
% plot topography

figure('units','normalized','outerposition',[0 0 1 .5])
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

saveas(gcf,fullfile(Paths.Results, [ Task, '_', Normalization, ...
    '_', Subset, '_Retention_Topos_by_Level.svg']))


figure('units','normalized','outerposition',[0 0 1 .5])
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

saveas(gcf,fullfile(Paths.Results, [ Task, '_', Normalization, ...
    '_', Subset, '_Encoding_Topos_by_Level.svg']))
% TODO: BL, normalizes trial by baseline just prior


