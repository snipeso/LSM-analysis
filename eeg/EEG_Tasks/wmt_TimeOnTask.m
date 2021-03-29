clear
close all
clc


EEGT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Normalization = 'zscore'; % 'zscore', TODO: 'BL'
Refresh = false;

Freqs = 1:.25:40;
Hotspot = 'Hotspot';
YLim = [-.2 1.4];
Band = 'Theta';
TotBins = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Match2Sample';
Condition = 'BAT';
EEG_Type = 'Wake';
Legend = {'Baseline', 'Encoding', 'Retention'};
Colors = [Format.Colors.Generic.Dark1; Format.Colors.Generic.Red; Format.Colors.Generic.Pale2];
Window = 4;

EndBL_Trigger = Epochs.(Task).Baseline.Trigger;
StartRT_Trigger = 'S 10'; % start fixatio

Paths.Results = string(fullfile(Paths.Results, 'PowerTasks'));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

Sessions = Format.Labels.(Task).(Condition).Sessions;
SessionLabels = Format.Labels.(Task).(Condition).Plot;

SummaryFile = fullfile(Paths.Matrices, [Task '_', Normalization, '_', num2str(TotBins), '_WelchPower_TimeOnTask.mat']);
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

    
    % assemble matrix: participant x session x condition x ch x freq
    % conditions: n1, n3, n6
    % save BL and encoding matrix participant x session x ch x freq
    Power = nan(numel(Participants), numel(Sessions), 3, TotBins);
    
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
            
            % Get Bin for each trial
            Edges = round(linspace(0, size(Trials, 1), TotBins+1));
            Bins = discretize(1:size(Trials, 1), Edges); 
            
            % select only trials that are in specified subset & remove
            % missing responses
                    Remove = Trials.missed;

            EndBaselines(Remove) = [];
            StartRetentions(Remove) = [];
            Trials(Remove, :) = [];
            Bins(Remove) = [];
            
            % calculate power
            StartBaselines = EndBaselines- round(Window*fs);
            EndRetentions = StartRetentions + round(Window*fs);
            
            R_Power = PowerTrials(EEG, Freqs, StartRetentions, EndRetentions);
            BL_Power = PowerTrials(EEG, Freqs, StartBaselines, EndBaselines);
            E_Power = PowerTrials(EEG, Freqs, EndBaselines, StartRetentions);
            
            % save, split by bin
            for Indx_B = 1:TotBins
                T = Bins == Indx_B;                
                
                Power(Indx_P, Indx_S, 1, Indx_B, 1:numel(Chanlocs), 1:numel(Freqs)) = ...
                    nanmean(BL_Power(T, :, :), 1);
                 Power(Indx_P, Indx_S, 2, Indx_B, 1:numel(Chanlocs), 1:numel(Freqs)) = ...
                    nanmean(E_Power(T, :, :), 1);
                 Power(Indx_P, Indx_S, 3, Indx_B, 1:numel(Chanlocs), 1:numel(Freqs)) = ...
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
                for Indx_E = 1:3
                for Indx_B = 1:TotBins
                    for Indx_C = 1:numel(Chanlocs)
                        R = squeeze(Power(Indx_P, Indx_S, Indx_E, Indx_B, Indx_C, :))';
                        Power(Indx_P, Indx_S, Indx_E, Indx_B, Indx_C, :) = (R-MEAN')./SD';
                    end
                end
                end
            end
        end
        
    end
    save(SummaryFile, 'Power', 'Chanlocs', 'Freqs')
else
    load(SummaryFile, 'Power', 'Chanlocs', 'Freqs')
end


%%
TitleInfo = {Task, Normalization, Hotspot, Band, num2str(TotBins),};
TitleTag = strjoin(TitleInfo, '_'); % TODO!


% plot split by level for each session
figure('units','normalized','outerposition',[0 0 1 .5])
FreqsIndxBand =  dsearchn( Freqs', Bands.(Band)');
Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
for Indx_S = 1:numel(Sessions)
    Matrix = squeeze(nanmean(nanmean(Power(:, Indx_S, :, :, Indexes_Hotspot, FreqsIndxBand),5),6));
    Matrix = permute(Matrix, [1, 3, 2]);
    subplot(1, numel(Sessions), Indx_S)
    PlotSpaghettiOs(Matrix, 1, 1:TotBins, Legend, Colors, Format)
    title([strjoin({'ToT Power ', SessionLabels{Indx_S}, Hotspot, Band}, ' ')])
    xlabel('Bin')
end
NewLims = SetLims(1, 3, 'y');

saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_Time_On_Task_Hotspot.svg']))



% plot spectrograms for each type
figure('units','normalized','outerposition',[0 0 1 1])
FreqsIndxBand =  dsearchn( Freqs', Bands.(Band)');
Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
Indx = 1;
for Indx_E = 1:3
for Indx_S = 1:numel(Sessions)
  
    Matrix = squeeze(nanmean(Power(:, Indx_S, Indx_E, :, Indexes_Hotspot, :),5));
    subplot(3, numel(Sessions), Indx)
     PlotPowerHighlight(Matrix, Freqs, FreqsIndxBand, Format.Colors.RRT.Sessions(3:TotBins+3, :), ...
         Format, string(1:TotBins))
    title([strjoin({'ToT Power ', SessionLabels{Indx_S}, Legend{Indx_E}, Hotspot, Band}, ' ')])
    xlabel('Bin')
    Indx = Indx+1;
end
end
NewLims = SetLims(3, numel(Sessions), 'y');

saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_Time_On_Task_Spectrum.svg']))

