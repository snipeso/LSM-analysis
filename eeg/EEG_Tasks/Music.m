


clear
close all
clc


EEGT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



Normalization = 'zscore'; % 'zscore', TODO: 'BL'
Refresh = false;

Freqs = 1:.25:40;
Window = 4; % in seconds
Hotspot = 'Hotspot';
% YLim = [-.2 1.4];
Band = 'Theta';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Music';
Condition = 'BAT';
EEG_Type = 'Wake';

Legend = {'GOT', 'Tell'};
Colors = [Format.Colors.Generic.Dark1; Format.Colors.Generic.Red];


Paths.Results = string(fullfile(Paths.Results, 'PowerTasks'));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end


Sessions = Format.Labels.(Task).(Condition).Sessions;
SessionLabels = Format.Labels.(Task).(Condition).Plot;

SummaryFile = fullfile(Paths.Matrices, [Task '_', Normalization, '_WelchPower.mat']);
if Refresh || ~exist(SummaryFile, 'file')
    
    % get response times
    Responses = [Task, '_AllAnswers.mat'];
    if  ~Refresh &&  exist(fullfile(Paths.Responses, Responses), 'file')
        load(fullfile(Paths.Responses, Responses), 'Answers')
    else
        if ~exist(Paths.Responses, 'dir')
            mkdir(Paths.Responses)
        end
        AllAnswers = importTask(Paths.Datasets, Task, Paths.Responses); % needs to have access to raw data folder
        Answers = cleanupMusic(AllAnswers);
        save(fullfile(Paths.Responses, Responses), 'Answers');
    end
    
    
    TotSongs = numel(unique(Answers.song));
    
    % assemble matrix: participant x session x condition x ch x freq
    % conditions: n1, n3, n6
    % save BL and encoding matrix participant x session x ch x freq
    Power = nan(numel(Participants), numel(Sessions), TotSongs);
    GOT_Position = nan(numel(Participants), numel(Sessions));
    Tell_Position = GOT_Position; % Too lazy to figure out a smart way to do this
    
    % get eeg data
    for Indx_P = 1:numel(Participants)
        
        % for zscoring
        SUM = zeros(1, numel(Freqs));
        SUMSQ = zeros(1, numel(Freqs));
        N = 0;
        
        for Indx_S = 1:numel(Sessions)
            Participant = Participants{Indx_P};
            
            % get subtable
            Order = Answers.song(strcmp(Answers.Participant, Participant)& ...
                strcmp(Answers.Session, Sessions{Indx_S}));
            
            if numel(Order)~=2
                 warning(['Problem with song data ', EEG_Filename])
                 continue
            end
            % assign song type
            switch Order(1)
                case 'GOT.wav'
                    GOT_Position(Indx_P, Indx_S) = 1;
                    Tell_Position(Indx_P, Indx_S) = 2;
                case 'Tell.wav'
                     GOT_Position(Indx_P, Indx_S) = 2;
                    Tell_Position(Indx_P, Indx_S) = 1;
                otherwise
                    warning(['Problem with song data ', EEG_Filename])
            end
                    
            
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
            StartSongs =  AllTriggerTimes(strcmp(AllTriggerTypes, EEG_Triggers.Stim));
            EndSongs =  AllTriggerTimes(find(strcmp(AllTriggerTypes, EEG_Triggers.Stim))+1);
            
            if numel(StartSongs) ~= TotSongs
                warning(['Problem with triggers for ', EEG_Filename])
                continue
            end
            
            % calculate power
            for Indx_So = 1:TotSongs
                Starts = StartSongs(Indx_So):round(Window*fs):EndSongs(Indx_So);
                Ends = Starts(2:end);
                Starts = Starts(1:end-1);
                Song_Power = PowerTrials(EEG, Freqs, Starts, Ends);
                Song = squeeze(nanmean(Song_Power, 1));
                Power(Indx_P, Indx_S, Indx_So, 1:numel(Chanlocs), 1:numel(Freqs)) = Song;
                
                SUM = SUM + nansum(Song, 1);
                SUMSQ = SUMSQ + nansum(Song.^2, 1);
                N = N + numel(Song(:, 1));
            end
            
        end
        
        
        if strcmp(Normalization, 'zscore')
            MEAN = SUM./N;
            SD = sqrt((SUMSQ - N.*(MEAN.^2))./(N - 1));
            
            for Indx_S =1:numel(Sessions)
                for Indx_So = 1:TotSongs
                    for Indx_C = 1:numel(Chanlocs)
                        Data =  squeeze(Power(Indx_P, Indx_S, Indx_So, Indx_C, :))';
                        Power(Indx_P, Indx_S, Indx_So, Indx_C, :) = (Data'-MEAN')./SD';
                    end
                end
            end
        end
        
    end
    save(SummaryFile, 'Power', 'GOT_Position', 'Tell_Position', 'Chanlocs')
else
    load(SummaryFile,  'Power','GOT_Position', 'Tell_Position', 'Chanlocs')
end

%%

Levels = 1:3;


TitleInfo = {Task, Normalization, Hotspot, Band};
TitleTag = strjoin(TitleInfo, '_'); % TODO!

% plot song 1 vs song 2 for each session
figure('units','normalized','outerposition',[0 0 1 .5])
FreqsIndxBand =  dsearchn( Freqs', Bands.(Band)');
Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
for Indx_S = 1:numel(Sessions)
    Matrix = squeeze(nanmean(Power(:, Indx_S, :, Indexes_Hotspot, :), 4));
    
    subplot(1, numel(Sessions), Indx_S)
    PlotPowerHighlight(Matrix, Freqs, FreqsIndxBand, Colors, Format, {'First Song', 'Second Song'})
    title([strjoin({'Songs', SessionLabels{Indx_S}, Hotspot, Band}, ' ')])
    if exist('YLim', 'var')
        ylim(YLim)
    end
    xlim([0 30])
end
NewLims = SetLims(1, 3, 'y');
saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_Power_SongOrder.svg']))


% topography diff between two
figure('units','normalized','outerposition',[0 0 .5 .5])

for Indx_S = 1:numel(Sessions)
    S1 =  squeeze(nanmean(nanmean(Power(:, Indx_S, 1, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5),3));
    S2 = squeeze(nanmean(Power(:, Indx_S, 2, :, FreqsIndxBand(1):FreqsIndxBand(2)), 5));
    subplot(1, numel(Sessions), Indx_S)
    PlotTopoDiff(S1, S2, Chanlocs, [-5 5], Format)
    title([Band, ' ', SessionLabels{Indx_S}])
end
saveas(gcf,fullfile(Paths.Results, [TitleTag, '_Topo_SongOrder.svg']))


% plot GOT vs Tell


figure('units','normalized','outerposition',[0 0 1 .5])
FreqsIndxBand =  dsearchn( Freqs', Bands.(Band)');
Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
for Indx_S = 1:numel(Sessions)
    Matrix = squeeze(nanmean(Power(:, Indx_S, :, Indexes_Hotspot, :), 4));
    
    Combo = nan(size(Matrix));
    Tell = nan(size(Matrix));
    for Indx_P = 1:numel(Participants)
    Combo(Indx_P, 1, :) = Matrix(Indx_P, GOT_Position(Indx_P, Indx_S), :);
    Combo(Indx_P, 2, :) =  Matrix(Indx_P, Tell_Position(Indx_P, Indx_S), :);
   
    end

    subplot(1, numel(Sessions), Indx_S)
    PlotPowerHighlight(Combo, Freqs, FreqsIndxBand, Colors, Format, Legend)
    title([strjoin({'Songs', SessionLabels{Indx_S}, Hotspot, Band}, ' ')])
    if exist('YLim', 'var')
        ylim(YLim)
    end
    xlim([0 30])
end
NewLims = SetLims(1, 3, 'y');
saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_Power_SongType.svg']))

% spectrum


% topography