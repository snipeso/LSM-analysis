

ERP_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Condition = 'RRT';
Refresh = true;

Window = [-1, 2];
BL_Window = [-.75 -.25];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Oddball';
Target_Trigger = 'S 10';
Standard_Trigger = 'S 11';

Ch = 6;

Title_Tag = [Task, '_', Condition];

Sessions = Format.Labels.(Task).(Condition).Sessions;
SessionLabels = Format.Labels.(Task).(Condition).Plot;


%%% load data
ERP_Filename = [Title_Tag, '_ERPmatrix.mat'];
if Refresh || ~exist(fullfile(Paths.Summary, ERP_Filename), 'file')
    
    Source = fullfile(Paths.Preprocessed, 'Interpolated', 'ERP', Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Task);
    
    Targets = nan(numel(Participants), numel(Sessions));
    Standards = Targets;
    
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            EEG_Filename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, '_Clean.set'}, '_');
            
            if ~exist(fullfile(Source, EEG_Filename), 'file')
                continue
            end
            
            EEG = pop_loadset('filename',EEG_Filename, 'filepath', Source);
            
            Chanlocs = EEG.chanlocs;
            
            % set noise to NaN
            Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(EEG_Filename, '_Clean'), ...
                '_Cleaning_Cuts.mat']);
            EEG = nanNoise(EEG, Cuts_Filepath);
            
            % get ERPs
            Target_ERPs = ChopERPs(EEG, Target_Trigger, Window, BL_Window);
            Standard_ERPs = ChopERPs(EEG, Target_Trigger, Window, BL_Window);
            
            Points = size(Target_ERPs, 2);
            
            Targets(Indx_P, Indx_S, 1:numel(Chanlocs), 1:Points) = nanmean(Target_ERPs, 1);
            Standards(Indx_P, Indx_S, 1:numel(Chanlocs), 1:Points) = nanmean(Standard_ERPs, 1);
        end
    end
    
    % save to matrix
    save(fullfile(Paths.Summary, ERP_Filename), 'Targets', 'Standards', 'Chanlocs', 'Points')
else
    load(fullfile(Paths.Summary, ERP_Filename), 'Targets', 'Standards', 'Chanlocs', 'Points')
end


ChanIndx = ismember( str2double({Chanlocs.labels}), Ch);


% plot grid of ERPs, target  & standard, like elias
figure('units','normalized','outerposition',[0 0 1 1])
t = linspace(Window(1), Window(2), Points);
for Indx_S = 1:numel(Sessions)
    subplot(3, 4, Indx_S)
    hold on
    T =  squeeze(nanmean(Targets(:, Indx_S, ChanIndx, :), 3));
    S = squeeze(nanmean(Standards(:, Indx_S, ChanIndx, :), 3));
    plot(t, nanmean(T,1), ...
        'LineWidth', 2, 'Color', Format.Colors.Generic.Red)
    
    plot(t, nanmean(S,1), ...
        'LineWidth', 2, 'Color', Format.Colors.Generic.Dark1)
    
    TimeSeriesStats(cat(3, T, S), t, 200)
end

% identify P100, P200, P300 peaks, save amplitude to matrix


