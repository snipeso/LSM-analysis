

clear
close all
clc


EEGT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



Normalization = ''; % 'zscore', TODO: 'BL'
Refresh = true;

Freqs = 1:.25:40;
Subset = 'All'; % 'All', 'Correct', 'Incorrect'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Match2Sample';
Condition = 'BAT';
EEG_Type = 'Wake';
Window = 4;

EndBL_Trigger = 'S  3';
StartRT_Trigger = 'S 10';

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
            
            
            if size(Trials, 1) ~= EndBaselines || size(Trials, 1) ~= StartRetentions
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

            EndBaselines(Remove, :, :) = [];
            StartRetentions(Remove, :, :) = [];
            Trials(Remove, :) = [];
            
            R_Power = nan(size(Trials, 1), numel(Chanlocs), numel(Freqs));
            BL_Power = R_Power;
            E_Power = R_Power;
            
            for Indx_T = 1:numel(Trials)
                EndBL = EndBaselines(Indx_T);
                StartBL = EndBL - round(Window*fs);
                
                StartRT = StartRetentions(Indx_T);
                EndRT = StartRT + round(Window*fs);
                
                BL_Data = EEG.data(:,StartBL:EndBL);
                pxx = pwelch(BL_Data', [], 0, Freqs, fs)';
                BL_Power(Indx_T, :, :) = pxx;
                
                E_Data = EEG.data(:, EndBL:StartRT);
                pxx = pwelch(E_Data', [], 0, Freqs, fs)';
                E_Power(Indx_T, :, :) = pxx;
                
                R_Data = EEG.data(:, StartRT:EndRT);
                pxx = pwelch(R_Data', [], 0, Freqs, fs)';
                R_Power(Indx_T, :, :) = pxx;
            end
            
%              Retention = nan(numel(Participants), numel(Sessions), numel(Levels));

            % save split by level
            for Indx_L = 1:numel(Levels)
                T = Trials.level == Levels(Indx_L);
                
                Baseline(Indx_P, Indx_S, Indx_L, 1:numel(Chanlocs), 1:numel(Freqs)) = ...
                    nanmean();
                
                
            end
            
            
            
            
        end
    end
    
    
    
else
    load(SummaryFile, 'Retention', 'Baseline', 'Encoding', 'Chanlocs')
end


% S3: show symbols (4s prior are BL)
% s10: start retention period

% get behavioral data

% assemble matrix: participant x session x condition x ch x freq
% conditions: n1, n3, n6
% save BL and encoding matrix participant x session x ch x freq


% try normal z scoring first: zscore whole thing by participants

% TODO: BL, normalizes trial by baseline just prior

% plot for each session each condition power

% plot average across sessions

% plot split by correct vs incorrect responses