clear
clc
close all

ERP_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Task = 'LAT';

Condition = 'AllBeam';
Title = 'All';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Sessions = allSessions.([Task,Condition]);
SessionLabels = allSessionLabels.([Task, Condition]);

Paths.Figures = fullfile(Paths.Figures, 'Tones', Task);
if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end

% get data by loading all files, or by opening existing file
FFT_Path = fullfile(Paths.Summary, [Task, '_FFT.mat']);
if ~exist(FFT_Path, 'file') || Refresh
    disp('*************Creating allFFT********************')
    load('Chanlocs111.mat', 'Chanlocs')
    [allFFT, Categories] = LoadAllFFT(fullfile(Paths.WelchPower, Task), 'Power'); % TODO: convert to being generic
    save(FFT_Path, 'allFFT', 'Categories')
else
    disp('***************Loading allFFT*********************')
    load(FFT_Path, 'allFFT', 'Categories')
end


% 