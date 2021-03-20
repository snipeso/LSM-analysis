clear
clc
close all

wp_Parameters


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;
Normalization = 'zscore';
Tag = 'TaskPowerDiffs';
Hotspot = 'Hotspot';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks =  Format.Tasks.BAT;
RRT = Format.Tasks.RRT;
TasksLabels = Format.Tasks.BAT;
RRTLabels = Format.Tasks.RRT;

AllTasks = [Tasks, RRT];
AllTaskLabels = [TasksLabels, RRTLabels];

Sessions_BAT = Format.Labels.(Tasks{1}).BAT.Sessions;
Sessions_RRT = Format.Labels.(RRT{1}).BAT.Sessions;
Sessions_RRT2 = Format.Labels.(RRT{1}).BAT2.Sessions;


SessionLabels = Format.Labels.(Tasks{1}).BAT.Plot;

CompareTaskSessions = {'Baseline', 'Session2'};


Paths.Results = string(fullfile(Paths.Results, Tag));
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

SummaryFile = fullfile(Paths.Summary, strjoin({Tag, Normalization, '_Power.mat'}, '_'));
if Refresh || not(exist(SummaryMatrix, 'file'))
    
    AllPower = nan(numel(Participants), numel(SessionLabels), numel(AllTasks));
    
    for Indx_P = 1:numel(Participants)
        
        for Indx_T = 1:numel(Tasks)
            
            Sessions = Format.Labels.(Tasks{Indx_T}).BAT.Sessions;
            for Indx_S = 1:numel(Sessions)
                PowerPath = fullfile(Paths.WelchPower, Tasks{Indx_T});
                Filename = strjoin({Participants{Indx_P}, Tasks{Indx_T}, Sessions{Indx_S}, 'wp.mat'},'_');
                
                if ~exist(fullfile(PowerPath, Filename), 'file')
                    warning(['Cant find power for ', Filename])
                    continue
                end
                
                load(fullfile(PowerPath, Filename), 'Power')
                
                FFT = Power.FFT;
                Freqs = Power.Freqs;
                Chanlocs = Power.Chanlocs;
                
                AllPower(Indx_P, Indx_S, Indx_T, 1:numel(Chanlocs), 1:numel(Freqs)) = nanmean(FFT, 3);
                
            end
        end
        
        Indx = Indx_T+1;
        for Indx_S = 1:numel(Sessions_RRT)
            for Indx_T = 1:numel(RRT)
                FFT_Combo = nan(numel(Chanlocs), numel(Freqs), 2);
                PowerPath = fullfile(Paths.WelchPower, RRT{Indx_T});
                % load first file for each session
                Filename = strjoin({Participants{Indx_P}, RRT{Indx_T}, Sessions_RRT{Indx_S}, 'wp.mat'},'_');
                
                if ~exist(fullfile(PowerPath, Filename), 'file')
                    warning(['Cant find power for ', Filename])
                else
                    load(fullfile(PowerPath, Filename), 'Power')
                    FFT_Combo(:, :, 1) = nanmean(Power.FFT,3);
                end
                
                
                % load second file for each session
                Filename = strjoin({Participants{Indx_P}, RRT{Indx_T}, Sessions_RRT2{Indx_S}, 'wp.mat'},'_');
                
                if ~exist(fullfile(PowerPath, Filename), 'file')
                    warning(['Cant find power for ', Filename])
                else
                    load(fullfile(PowerPath, Filename), 'Power')
                    FFT_Combo(:, :, 1) = nanmean(Power.FFT,3);
                end
                
                
                % average and save to general matrix
                AllPower(Indx_P, Indx_S, Indx, 1:numel(Chanlocs), 1:numel(Freqs)) = nanmean(FFT_Combo, 3);
                Indx = Indx+1;
            end
        end
    end
    
    AllPower(AllPower==0) = nan;
    save(SummaryFile, 'AllPower', 'Freqs', 'Chanlocs')
else
    load(SummaryFile, 'AllPower', 'Freqs', 'Chanlocs')
end


%%

% z-scoring
if strcmp(Normalization, 'z-score')
    for Indx_P = 1:numel(Participants)
        for Indx_F = 1:numel(Freqs)
            D = AllPower(Indx_P, :, :, :, Indx_F);
            Mean = nanmean(D(:));
            STD = nanstd(D(:));
            AllPower(Indx_P, :, :, :, Indx_F) = (D-Mean)./STD;
        end
    end
end

%%

AllBands = fieldnames(Bands);

 Indexes_Hotspot =  ismember( str2double({Chanlocs.labels}), EEG_Channels.(Hotspot));
               
 FixIndx = find(strcmp(AllTasks, 'Fixation'));
for Indx_B = 2 %1:numel(AllBands)
    Band = AllBands{Indx_B};
    TitleTag = strjoin({Tag, Normalization, Band}, '_');
    
    FreqsIndxBand =  dsearchn( Freqs', Bands.(Band)');
    % plot difference from Fixation
    
    for Indx_S = 1:numel(SessionLabels)
        
        Fix = squeeze(nanmean(AllPower(:, Indx_S, FixIndx, Indexes_Hotspot, :),4));
        
        figure('units','normalized','outerposition',[0 0 1 1])
        
        for Indx_T =1:numel(AllTasks)-1
            Task = AllTasks{Indx_T};
            
            T =  squeeze(nanmean(AllPower(:, Indx_S, Indx_T, Indexes_Hotspot, :),4));
            Matrix = cat(3, Fix, T);
            Matrix = permute(Matrix, [1,3,2]);
            
            
            subplot(3, 3, Indx_T)
            PlotPowerHighlight(Matrix, Freqs, FreqsIndxBand, ...
                Format.Colors.Tasks.(Task), Format)
            title(strjoin({AllTaskLabels{Indx_T}, 'vs Fix at',  SessionLabels{Indx_S}}, ' '))
            ylabel('Amplitude')
            xlim([1 25])
            
        end
        NewLims = SetLims(3, 3, 'y');
        saveas(gcf,fullfile(Paths.Results, [TitleTag,  '_', SessionLabels{Indx_S}, '_HotspotPowerChange.svg']))
    end
    % plot hotspot spectrums of all tasks by session
    
    
    % plot spaghettiOs with task on x axis, session as strings
    
    
    
end


% plot topos of all tasks vs fixation