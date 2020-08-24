

plotERP_Parameters
ERP_Parameters

%%% condition specific variables
switch Condition
    case 'Beam'
        Condition = 'AllBeam';
        Title = 'Soporific';
        DataTag = [Task, '_', Title];
    case 'BL'
        Title = 'Baseline';
         DataTag = [Task, '_', Title];
    case 'SD'
        Condition = 'SD3';
        Title = 'SleepDep';
         DataTag = [Task, '_', Title];
    case 'BLvSD'
        Condition = 'AllBeam';
        Title = 'BLvSD';
         DataTag = [Task, '_', Title];
end

% labels and indices
Sessions = allSessions.([Task, Condition]);
SessionLabels = allSessionLabels.([Task, Condition]);

TitleTag = [Title, '_', Task];

ERPpoints = newfs*(Stop-Start);
Powerpoints = HilbertFS*(Stop-Start);

% locations
Paths.Figures = fullfile(Paths.Figures, 'Trials', Task);
if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end


%%% get ERPs locked to stim and resp
Struct_Path_Data = fullfile(Paths.Summary, [DataTag, '_TrialERPs.mat']);
if ~exist(Struct_Path_Data, 'file') || Refresh
    disp('*************Creating allTrials********************')
    
    
    Path = fullfile(Paths.ERPs, 'Trials', Task);
    Files = deblank(cellstr(ls(Path)));
    Files(~contains(Files, '.mat')) = [];
    
    
    % initialize structures for all data % TODO, get rid of!
    allEvents = struct();
    
    Stim = struct(); % data
    StimPower = struct();
    Resp = struct();
    RespPower = struct();
    StimPhases = struct(); % ch x trials
    RespPhases = struct();
    
    
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            
            % load data
            File = Files(contains(Files, Sessions{Indx_S}) & contains(Files, Participants{Indx_P}));
            
            if isempty(File)
                warning(['**************Could not find ', Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])
                continue
            end
            
            m = matfile(fullfile(Path, File{1}),  'Writable', false );
            
            Trials = m.Events;
            Remove = Trials.Noise==1;
            Trials(Remove, :) = [];
            
            
            if isempty(Trials)
                warning(['**************Could not find ', Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])
                continue
            end
            

            %%% get ERPs
            Data  =   m.Data;
            Power = m.Power;
            Phase = m.Phase;
            Meta = m.Meta;
            Chanlocs = m.Chanlocs;
            
            % initialize matrices
            Stim(Indx_P).(Sessions{Indx_S}) = nan(numel(Chanlocs), ERPpoints, numel(Data));
            Resp(Indx_P).(Sessions{Indx_S}) =  nan(numel(Chanlocs), ERPpoints, numel(Data));
            
            for Indx_B = 1:numel(BandNames) % TODO, eventually find a better way
                StimPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}) =  nan(numel(Chanlocs), Powerpoints, numel(Data));
                StimPhases.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}) =  nan(numel(Chanlocs), numel(1:PhasePeriod*HilbertFS:Powerpoints), numel(Data));
                RespPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}) =  nan(numel(Chanlocs), Powerpoints, numel(Data));
                RespPhases.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}) =  nan(numel(Chanlocs), numel(1:PhasePeriod*HilbertFS:Powerpoints), numel(Data));
                
            end
            
            allEvents(Indx_P).(Sessions{Indx_S}) = Trials;
            for Indx_T = 1:numel(Data)
                if Remove(Indx_T)
                    continue
                end
                
                % get ERPs
                Stim(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = Data(Indx_T).EEG(:, 1:ERPpoints);
                
                if ~isnan(Meta(Indx_T).Resp)
                    rStart = Meta(Indx_T).Resp + Start;
                    rStop = Meta(Indx_T).Resp + Stop;
                    
                    Resp(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = Data(Indx_T).EEG(:, round(newfs*rStart):(round(newfs*rStop)-1));
                else
                    Resp(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = nan(numel(Chanlocs), ERPpoints);
                end
                
                % get power and phase
                for Indx_B = 1:numel(BandNames)
                    StimPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = Power(Indx_T).(BandNames{Indx_B})(:, 1:Powerpoints);
                    StimPhases.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = Phase(Indx_T).(BandNames{Indx_B})(:, 1:PhasePeriod*HilbertFS:Powerpoints);
                    
                    
                    if ~isnan(Meta(Indx_T).Resp)
                        RespPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = Power(Indx_T).(BandNames{Indx_B})(:, round(HilbertFS*rStart):(round(HilbertFS*rStop)-1));
                        RespPhases.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = Phase(Indx_T).(BandNames{Indx_B})(:, round(HilbertFS*rStart):round(HilbertFS*PhasePeriod):(round(HilbertFS*rStop)-1));
                    else
                        RespPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = nan(numel(Chanlocs), Powerpoints);
                        RespPhases.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = nan(numel(Chanlocs), numel(1:PhasePeriod*HilbertFS:Powerpoints));
                    end
                end
            end
            % Remove bad epochs
            Stim(Indx_P).(Sessions{Indx_S})(:, :,  Remove) = [];
            Resp(Indx_P).(Sessions{Indx_S})(:, :, Remove) = [];
            
            for Indx_B = 1:numel(BandNames) % TODO, eventually find a better way
                StimPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :,  Remove) = [];
                StimPhases.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Remove) = [];
                RespPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :,  Remove) = [];
            end
            
        end
    end
    
    Chanlocs = m.Chanlocs;
    
    % Get zscores for participants
    [Means, SDs] = GetZscorePower(Path, Participants, Chanlocs, BandNames);
    
    save(Struct_Path_Data, 'Stim', 'allEvents', 'StimPower', ...
        'Resp', 'RespPower', 'StimPhases', 'RespPhases', 'Means', 'SDs', 'Chanlocs', '-v7.3')
else
    disp('***************Loading ERPs*********************')
    load(Struct_Path_Data)
end


% Normalize power data
if Normalize
    StimPower = ZScorePower(StimPower, Means, SDs);
    RespPower = ZScorePower(RespPower, Means, SDs);
end


% get fancy groups for dividing trials
Load_TrialQuantiles


