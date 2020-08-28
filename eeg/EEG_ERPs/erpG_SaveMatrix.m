% script to get average of the ERP component for each participant/session


clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'LAT', 'PVT'};
Conditions = {'Beam', 'Comp'};
ConditionTitles = {'Soporific', 'Classic'};

Stimulus = 'Resp';
TimeWindow = [0 .25];
Channel = EEG_Channels.ERP(2);

Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ERP_Parameters
plotERP_Parameters

TimePoints = round((TimeWindow-Start)*newfs);
[~, PlotChannel] = intersect({Chanlocs.labels}, string(Channel));

ERPWindow = Stop - Start;
Period = 1/newfs;

% time arrays
t = linspace(Start, Stop, ERPWindow*newfs);

for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};
    Destination = fullfile(Paths.Analysis, 'statistics', 'Data', Task); % for statistics
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    
    allData = struct();
    
    for Indx_C = 1:numel(Conditions)
        Condition = Conditions{Indx_C};
        Title = ConditionTitles{Indx_C};
        
        Sessions = allSessions.([Task,Condition]);
        SessionLabels = allSessionLabels.([Task, Condition]);
        
        %%%% Get data
        Path = fullfile(Paths.ERPs, 'SimpleERP', Stimulus, Task);
        
        Matrix = nan(numel(Participants), numel(Sessions));
        for Indx_P = 1:numel(Participants)
            for Indx_S = 1:numel(Sessions)
                File = Files(contains(Files, Sessions{Indx_S}) & ...
                    contains(Files, Participants{Indx_P}));
                
                
                if isempty(File)
                    warning(['**************Could not find ', ...
                        Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])
                    continue
                end
                
                m = matfile(fullfile(Path, File{1}), 'Writable', false);
                
                % skip if no trials present
                if isempty(m.Data)
                    disp(['**** Skipping ', File{1}, ' ****'])
                    continue
                end
                Data = m.Data;
                allData(Indx_P).(Sessions{Indx_S}) = Data;
                
                % get integral at requested range (excluding parts with
                % opposite sign)
                MeanPeak = squeeze(nanmean(Data(PlotChannel, TimePoints(1):TimePoints(2), :), 3));
                MainSign = nanmean(MeanPeak)/ abs(nanmean(MeanPeak));
                MeanPeak( MeanPeak*MeanSign<0) = []; % remove parts of the opposite sign of the majority of the data in window
                
                
                
                Matrix(Indx_P, Indx_S) = sum(MeanPeak)*Period;
            end
        end
        
        Filename = [Task, saveFreqFields{Indx_F}, '_', Title, '.mat'];
        save(fullfile(Destination, Filename), 'Matrix')
        
    end
    
    PlotERP(t, allData, TriggerTime,  PlotChannel, 'Sessions', Format.Colors.(Task))
    Ax = gca;
    YLims = Ax.YLim;
    Y = YLims([1 1 2 2]);
    X = TimeWindow([1 2 2 1]);
    hold on
    patch('XData', X, 'YData', Y, 'FaceColor', [.5 .5 .5], 'FaceAlpha', .2, 'EdgeColor', 'none')

    title([Labels{Indx_Ch}, ' ', replace(TitleTag, '_', ' '), ' ERP by Session'])
    ylabel('miV')
    set(gca, 'FontSize', 14, 'FontName', Format.FontName)
    legend(fieldnames(allData))
    saveas(gcf,fullfile(Paths.Figures, [Task, '_AllSessions.svg']))
    
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
            Filename = [Task, '_back', saveFreqFields{Indx_F}, '_', Title, '.mat'];
            load(fullfile(Source, Filename), 'Matrix')
            AllTasks = cat(3, AllTasks, Matrix);
        end
        
        Matrix = nanmean(AllTasks, 3);
        Filename = ['AllTasks_back', saveFreqFields{Indx_F}, '_', Title, '.mat'];
        save(fullfile(Destination, Filename), 'Matrix')
    end
end