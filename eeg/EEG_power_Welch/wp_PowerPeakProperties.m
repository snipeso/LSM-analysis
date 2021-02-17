clear
clc
close all


wp_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'LAT', 'PVT', 'Match2Sample', 'SpFT', 'Game', 'Music'};
TasksLabels = {'LAT', 'PVT', 'WMT', 'Speech', 'Game', 'Music'};

Refresh = true;

TitleTag = 'PowerPeaks';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Paths.Results = string(fullfile(Paths.Results, 'FZK_03-2021'));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

Paths.Stats = string(fullfile(Paths.Analysis, 'statistics', 'Data', 'PowerPeaks'));
if ~exist(Paths.Stats, 'dir')
    mkdir(Paths.Stats)
end


for Indx_T = 1:numel(Tasks)

    Task = Tasks{Indx_T};
    
% in loop, load all files
PeaksPath = fullfile(Paths.Summary, [Task, '_PowerPeaks.mat']);

if ~Refresh || ~exist(PeaksPath, 'file')
    Sessions = allSessions.(Task);
    
     [PowerStruct, ~, ~] = LoadWelchData(Paths, {Task}, Sessions, Participants, 'none');
     
    M = nan(numel(Participants), numel(Sessions));
     PowerPeaks.Intercept = M;
     PowerPeaks.Slope = M;
      PowerPeaks.Peak = M;
      PowerPeaks.Amplitude = M;
      
      for Indx_P = 1:numel(Participants)
         for Indx_S = 1:numel(Sessions)
          [PowerPeaks.Intercept(Indx_P, Indx_S), ...
              PowerPeaks.Slope(Indx_P, Indx_S), ...
              PowerPeaks.Peak(Indx_P, Indx_S), ...
              PowerPeaks.Amplitude(Indx_P, Indx_S)] = SpectrumProperties(PowerStruct, Freqs);
         end
      end
     
     
    



% same as fzk, get hotspot spectrum, then individual channel spectrum


% get spectrum properties

else
    load(PeaksPath)
end

% export relevant matrices to Statistics folder


% plot confetti spaghetti of different variables across sessions


% average per task



end

% exiting loop, plot all tasks, split by session



% 
