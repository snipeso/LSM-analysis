

ERP_Parameters
plotERP_Parameters

% get trigger and possibly anything else
switch Condition
    case 'Beam'
        Condition = 'AllBeam';
        Title = 'Soporific';
    case 'BL'
        Title = 'Baseline';
    case 'SD'
        Condition = 'SD3';
        Title = 'SleepDep';
end

Sessions = allSessions.([Task,Condition]);
SessionLabels = allSessionLabels.([Task, Condition]);

% set figure destination
Paths.Figures = fullfile(Paths.Figures, Stimulus, Task);
if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end

%%%%%%%%%%%%%%%%
% Load tones

TitleTag = [Title, '_', Task, '_', Stimulus];
Struct_Path_Data = fullfile(Paths.Summary, [TitleTag, '_SimpleERP.mat']);

if ~exist(Struct_Path_Data, 'file') || Refresh
    
    disp(['************* Creating ', Title, ' ********************'])
    
    if contains(Stimulus, 'ISI')
        Path = fullfile(Paths.ERPs, 'SimpleERP', 'Intertrial');
    else
        Path = fullfile(Paths.ERPs, 'SimpleERP', Stimulus, Task);
    end
    Files = deblank(cellstr(ls(Path)));
    Files(~contains(Files, '.mat')) = [];
    
    allData =struct();
    allPhase =struct();
    allPower =struct();
    
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            File = Files(contains(Files, Sessions{Indx_S}) & ...
                contains(Files, Participants{Indx_P}));
            
            if isempty(File)
                warning(['**************Could not find ', ...
                    Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])
                continue
            end
            
            m = matfile(fullfile(Path, File{1}), 'Writable', false);
            
            % skip if no trials present
            if isempty(m.Data)
                disp(['**** Skipping ', File{1}, ' ****'])
                continue
            end
            
            allData(Indx_P).(Sessions{Indx_S}) = m.Data;
            allPhase(Indx_P).(Sessions{Indx_S})= m.Phase;
            
            for Indx_B = 1:numel(BandNames)
                if ndims(m.Power) < 4 % edge case of only 1 stimulus in recording
                    Power = m.Power(:, :, Indx_B);
                else
                    Power = squeeze(m.Power(:, :, Indx_B, :));
                end
                allPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}) = Power;
            end
        end
    end
    Chanlocs = m.Chanlocs;
    
    
    % Get zscores for participants
    PowerPath = fullfile(Paths.Summary, [TitleTag, 'SimpleERP_Power.mat']);
    [Means, SDs] = GetZscorePowerTemp(Path, Participants, Chanlocs, BandNames);
    
    
    save(Struct_Path_Data, 'allData', 'allPhase', 'Chanlocs', 'Means', 'SDs', '-v7.3')
    save(PowerPath, 'allPower', '-v7.3')
    
    
    
else
    
    disp(['*************** Loading ', Title, ' *********************'])
    load(Struct_Path_Data, 'allData', 'allPhase', 'Chanlocs', 'Means', 'SDs')
    load(fullfile(Paths.Summary, [TitleTag, 'SimpleERP_Power.mat']), 'allPower')
    
end

if Normalize
    allPower = ZScorePower(allPower, Means, SDs);
end
