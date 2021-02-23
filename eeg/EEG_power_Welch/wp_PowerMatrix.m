% script that gets a sinle value for delta, theta, alpha and beta for each
% participant at each session; specifically hotspot channels

clear
clc
close all

wp_Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false;
PlotSpectrums = false;
Normalization = '';
Condition = 'RRT';

Tag = 'PowerPeaks';
Hotspot = 'Hotspot'; % TODO: make sure this is in apporpriate figure name


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Tasks = Format.Tasks.(Condition);
TitleTag = strjoin({Tag, Normalization, Condition}, '_');

% make destination folders
Paths.Results = string(fullfile(Paths.Results, Tag));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

Paths.Stats = fullfile(Paths.Stats, Tag);
if ~exist(Paths.Stats, 'dir')
    mkdir(Paths.Stats)
end


for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};
    
    % in loop, load all files
    PeaksPath = fullfile(Paths.Summary, [Task, '_' Condition, '_PowerPeaks.mat']);
    PowerPath = fullfile(Paths.WelchPower, Task);
    Sessions = Format.Labels.(Task).(Condition).Sessions;
    SessionLabels = Format.Labels.(Task).(Condition).Plot;
    
        
        %%% Get data
        FFT_Path = fullfile(Paths.Summary, [Task, '_FFT.mat']);
        if ~exist(FFT_Path, 'file') || Refresh
            [allFFT, Categories] = LoadAllFFT(fullfile(Paths.WelchPower, Task), 'Power');
            save(FFT_Path, 'allFFT', 'Categories')
        else
            load(FFT_Path, 'allFFT', 'Categories')
        end
        
        Chanlocs = allFFT(1).Chanlocs;
        Freqs = allFFT(1).Freqs;
        TotChannels = size(Chanlocs, 2);
        
        
        % restructure data
        PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);
        ChanIndx = ismember( str2double({Chanlocs.labels}), EEG_Channels.Hotspot);

        
        for Indx_F = 1:numel(saveFreqFields) % loop through frequency bands
            FreqLims = saveFreqs.(saveFreqFields{Indx_F});
            FreqIndx =  dsearchn(Freqs', FreqLims');
            
            Matrix = nan(numel(Participants), numel(Sessions));
            for Indx_P = 1:numel(Participants)
                for Indx_S = 1:numel(Sessions)
                    if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                        continue
                    end
                    Power = PowerStruct(Indx_P).(Sessions{Indx_S})(ChanIndx, FreqIndx(1):FreqIndx(2), :);
                    Matrix(Indx_P, Indx_S) = nansum(nanmean(nanmean(Power, 3), 1))*FreqRes; % calculates the integral
                    
                end
            end
            Filename = [Task, saveFreqFields{Indx_F}, '_', Title, '.mat'];
            save(fullfile(Destination, Filename), 'Matrix')
        end

end


% save average across all tasks
Destination = fullfile(Paths.Analysis, 'statistics', 'Data', 'AllTasks');

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

for Indx_C = 1:numel(Conditions)
    Title = ConditionTitles{Indx_C};
    
    for Indx_F = 1:numel(saveFreqFields) % loop through frequency bands
        AllTasks = [];
        for Indx_T = 1:numel(Tasks)
            Task = Tasks{Indx_T};
            Source = fullfile(Paths.Analysis, 'statistics', 'Data', Task); % for statistics
            Filename = [Task, saveFreqFields{Indx_F}, '_', Title, '.mat'];
            load(fullfile(Source, Filename), 'Matrix')
            AllTasks = cat(3, AllTasks, Matrix);
        end
        
        Matrix = nanmean(AllTasks, 3);
        Filename = ['AllTasks', saveFreqFields{Indx_F}, '_', Title, '.mat'];
        save(fullfile(Destination, Filename), 'Matrix')
    end
end
