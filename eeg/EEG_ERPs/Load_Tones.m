clear
clc
close all

ERP_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Task = 'LAT';

Condition = 'AllBeam';
Title = 'AllBeam';
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
Struct_Path = fullfile(Paths.Summary, [Title, '_', Task, '_FFT.mat']);
if ~exist(Struct_Path, 'file') || Refresh
    disp('*************Creating allTones********************')


    Path = fullfile(Paths.ERPs, 'Tones', Task);
    Files = deblank(cellstr(ls(Path)));
    Files(~contains(Files, '.mat')) = [];
    
    allTones = struct();

    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
             File = Files(contains(Files, Sessions{Indx_S}) & contains(Files, Participants{Indx_P}));
             if isempty(File)
               warning(['**************Could not find ', Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])
                 continue
             end
             m = matfile(fullfile(Path, File{1}),  'Writable', false );
             allTones(Indx_P).(Sessions{Indx_S}).Data = m.Data;
              allTones(Indx_P).(Sessions{Indx_S}).Phase = m.Phase;
                allTones(Indx_P).(Sessions{Indx_S}).Power = m.Power; 
                
        end
    end

    
    save(Struct_Path, 'allTones', '-v7.3')
else
    disp('***************Loading allTones*********************')
    load(Struct_Path, 'allTones')
end


%