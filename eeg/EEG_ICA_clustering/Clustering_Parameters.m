
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))

Paths.Preprocessed = 'D:\Data\Preprocessed'; % LSM external hard disk

Paths.Figures = fullfile(Paths.Figures, 'HCA');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do stuff

if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end