
% get general parameters (script in main folder of LSM-analysis)
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))

%%% locations
Paths.Preprocessed = 'D:\Data\Preprocessed'; % Sophia laptop
Paths.Results = 'D:\Data\Results'; 

Paths.Summary = fullfile(mfilename('fullpath'), 'SummaryData');
Paths.WelchPower = fullfile(Paths.Preprocessed, 'Power', 'WelchPower');
Paths.Figures = fullfile(Paths.Figures, 'Welch');

% Parameters
FreqRes = 0.25;
Freqs = [1:FreqRes:30];
Window = 4; % window for epochs when looking at general power;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do stuff

if ~exist(Paths.Summary, 'dir')
    mkdir(Paths.Summary)
end
% 
% if ~exist('Sessions', 'var') &&  exist('Task', 'var')
%     Sessions = allSessions.([Task,Condition]);
%     SessionLabels = allSessionLabels.([Task, Condition]);
% elseif exist('Sessions', 'var')
%         SessionLabels = allSessionLabels.(Sessions);
%     Sessions = allSessions.(Sessions);
% end


Paths.Figures = fullfile(Paths.Figures, join(Tasks, '_'));
Paths.Figures = string(Paths.Figures );
if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end


