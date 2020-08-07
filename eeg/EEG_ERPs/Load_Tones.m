clear
clc
close all

ERP_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Task = 'LAT';

Condition = 'AllBeam';
Title = 'AllBeam';



% Condition = 'SD3';
% Title = 'SleepDep';

Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Sessions = allSessions.([Task,Condition]);
SessionLabels = allSessionLabels.([Task, Condition]);

Paths.Figures = fullfile(Paths.Figures, 'Tones', Task);
if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end

load('Chanlocs111.mat', 'Chanlocs')

% get data by loading all files, or by opening existing file
Struct_Path_Data = fullfile(Paths.Summary, [Title, '_', Task, '_Data.mat']);
if ~exist(Struct_Path_Data, 'file') || Refresh
    disp('*************Creating allTones********************')
    
    
    Path = fullfile(Paths.ERPs, 'Tones', Task);
    Files = deblank(cellstr(ls(Path)));
    Files(~contains(Files, '.mat')) = [];
    
    
    allData =struct();
    allPhase =struct();
    allPower =struct();
    
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            File = Files(contains(Files, Sessions{Indx_S}) & contains(Files, Participants{Indx_P}));
            if isempty(File)
                warning(['**************Could not find ', Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])
                continue
            end
            m = matfile(fullfile(Path, File{1}),  'Writable', false );
            allData(Indx_P).(Sessions{Indx_S}) = m.Data;
            allPhase(Indx_P).(Sessions{Indx_S})= m.Phase;
            
            for Indx_B = 1:numel(BandNames)
                allPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}) = squeeze(m.Power(:, :, Indx_B, :));
              
            end
            
        end
    end
    
    
    save(Struct_Path_Data, 'allData', '-v7.3')
    save(fullfile(Paths.Summary, [Title, '_', Task, '_Phase.mat']), 'allPhase')
    save(fullfile(Paths.Summary, [Title, '_', Task, '_Power.mat']), 'allPower', '-v7.3')
else
    disp('***************Loading allTones*********************')
    load(Struct_Path_Data, 'allTones')
    
    load(Struct_Path_Data, 'allData')
    load(fullfile(Paths.Summary, [Title, '_', Task, '_Phase.mat']), 'allPhase')
    load(fullfile(Paths.Summary, [Title, '_', Task, '_Power.mat']), 'allPower')
end


%