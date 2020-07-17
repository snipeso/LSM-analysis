% script that gets a sinle value for delta, theta, alpha and beta for each
% participant at each session; specifically hotspot channels

clear
clc
close all

wp_Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'LAT', 'PVT'};
Conditions = {'Beam', 'Comp'};
ConditionTitles = {'Soporific', 'Classic'};

Refresh = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};
    Destination = fullfile(Paths.Analysis, 'statistics', 'Data', Task); % for statistics
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    for Indx_C = 1:numel(Conditions)
        Condition = Conditions{Indx_C};
        Title = ConditionTitles{Indx_C};
        
        Sessions = allSessions.([Task,Condition]);
        SessionLabels = allSessionLabels.([Task, Condition]);
        
        
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
        
        TitleTag = [Task, '_', Title];
        
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
            Filename = [Task, '_', saveFreqFields{Indx_F}, '_', Title, '.mat'];
            save(fullfile(Destination, Filename), 'Matrix')
        end
    end
end


% save average
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
            Filename = [Task, '_', saveFreqFields{Indx_F}, '_', Title, '.mat'];
            load(fullfile(Source, Filename), 'Matrix')
            AllTasks = cat(3, AllTasks, Matrix);
        end
        
        Matrix = nanmean(AllTasks, 3);
        Filename = ['AllTasks_', saveFreqFields{Indx_F}, '_', Title, '.mat'];
        save(fullfile(Destination, Filename), 'Matrix')
    end
    
end
