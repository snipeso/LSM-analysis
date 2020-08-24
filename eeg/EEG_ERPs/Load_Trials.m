

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
        DataTag = [Task, '_Soporific'];
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


%%% get ERPs locked to stimuli and responses

Struct_Path_Data = fullfile(Paths.Summary, [DataTag, '_TrialERPs.mat']);
if ~exist(Struct_Path_Data, 'file') || Refresh
    disp(['************* Creating ', DataTag, ' ********************'])
    
    Path = fullfile(Paths.ERPs, 'Trials', Task);
    Files = deblank(cellstr(ls(Path)));
    Files(~contains(Files, '.mat')) = [];
    
    
    % initialize structures for all data
    allTrials = struct();
    
    Stim = struct(); % data
    Resp = struct();
    StimPower = struct();
    RespPower = struct();
    StimPhases = struct(); % ch x trials
    RespPhases = struct();
    
    
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            
            File = Files(contains(Files, Sessions{Indx_S}) & ...
                contains(Files, Participants{Indx_P}));
            
            if isempty(File)
                warning(['**************Could not find ', ...
                    Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])
                continue
            end
            
            m = matfile(fullfile(Path, File{1}),  'Writable', false );
            
            Trials = m.Trials;
            
            % continue if there aren't any trials
            if isempty(Trials)
                warning(['**************No trials for ', ...
                    Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])
                continue
            end
            
            
            %%% restructure data
            TotTrials = size(Trials, 1);
            Data  =   m.Data;
            Power = m.Power;
            Phase = m.Phase;
            Meta = m.Meta;
            Chanlocs = m.Chanlocs;
            
            allTrials(Indx_P).(Sessions{Indx_S}) = Trials;
            for Indx_T = 1:TotTrials
                
                % get ERPs
                Stim(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = Data(Indx_T).EEG(:, 1:ERPpoints);
                
                if ~isnan(Meta(Indx_T).Resp)
                    rStart = Meta(Indx_T).Resp + Start;
                    rStop = Meta(Indx_T).Resp + Stop;
                    
                    Resp(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = ...
                        Data(Indx_T).EEG(:, round(newfs*rStart):(round(newfs*rStop)-1));
                else
                    Resp(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = ...
                        nan(numel(Chanlocs), ERPpoints);
                end
                
                % get power and phase
                for Indx_B = 1:numel(BandNames)
                    StimPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = ...
                        Power(Indx_T).(BandNames{Indx_B})(:, 1:Powerpoints);
                    
                    PhasePoints = 1:PhasePeriod*HilbertFS:Powerpoints;
                    StimPhases.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = ...
                        Phase(Indx_T).(BandNames{Indx_B})(:, PhasePoints);
                    
                    
                    if ~isnan(Meta(Indx_T).Resp)
                        RespPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = ...
                            Power(Indx_T).(BandNames{Indx_B})(:, round(HilbertFS*rStart):(round(HilbertFS*rStop)-1));
                        
                        RespPhasePoints = round(HilbertFS*rStart):round(HilbertFS*PhasePeriod):(round(HilbertFS*rStop)-1);
                        RespPhases.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = ...
                            Phase(Indx_T).(BandNames{Indx_B})(:,RespPhasePoints);
                    else
                        RespPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = ...
                            nan(numel(Chanlocs), Powerpoints);
                        RespPhases.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S})(:, :, Indx_T) = ...
                            nan(numel(Chanlocs), numel(PhasePoints));
                    end
                end
            end
        end
    end
   
    % Get zscores for participants
    [Means, SDs] = GetZscorePower(Path, Participants, Chanlocs, BandNames);
    
    save(Struct_Path_Data, 'Stim', 'allTrials', 'StimPower', ...
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


