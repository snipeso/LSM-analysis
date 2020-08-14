

% load trials; remove periferal stim?

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

% Condition = 'AllBL';
% Title = 'AllBL';


Refresh = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Sessions = allSessions.([Task,Condition]);
SessionLabels = allSessionLabels.([Task, Condition]);

Paths.Figures = fullfile(Paths.Figures, 'Trials', Task);
if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end

load('Chanlocs111.mat', 'Chanlocs')

% get data by loading all files, or by opening existing file
Struct_Path_Data = fullfile(Paths.Summary, [Title, '_', Task, '_Data.mat']);
if ~exist(Struct_Path_Data, 'file') || Refresh
    disp('*************Creating allTrials********************')
    
    
    Path = fullfile(Paths.ERPs, 'Trials', Task);
    Files = deblank(cellstr(ls(Path)));
    Files(~contains(Files, '.mat')) = [];
    
    
    allData =struct();
    allEvents = struct();
    
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            File = Files(contains(Files, Sessions{Indx_S}) & contains(Files, Participants{Indx_P}));
            
            if isempty(File)
                warning(['**************Could not find ', Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])
                continue
            end

            m = matfile(fullfile(Path, File{1}),  'Writable', false );
            allData(Indx_P).(Sessions{Indx_S}) = m.Data;
            
            allEvents(Indx_P).(Sessions{Indx_S}) = m.Events;

        end
    end
    
    
%     save(Struct_Path_Data, 'allData', 'allEvents', '-v7.3')
else
    disp('***************Loading allTrials*********************')
    load(Struct_Path_Data, 'allData', 'allEvents')
end


%