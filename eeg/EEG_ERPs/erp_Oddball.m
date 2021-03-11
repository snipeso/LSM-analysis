

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
            EEG_Filename = strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}, 'Clean.set'}, '_');
            
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
            Standard_ERPs = ChopERPs(EEG, Standard_Trigger, Window, BL_Window);
            
            Points = size(Target_ERPs, 3);
            
            T =  nanmean(Target_ERPs, 1);
         
            Targets(Indx_P, Indx_S, 1:numel(Chanlocs), 1:Points) = T;
            
            
            % select only standards that come right before a target TEMP:
            % random selection
            Standard_ERPs = Standard_ERPs( randi(size(Standard_ERPs, 1), size(Target_ERPs, 1), 1), :, :);
            S = nanmean(Standard_ERPs, 1);
          
            Standards(Indx_P, Indx_S, 1:numel(Chanlocs), 1:Points) = S;
        end
    end
    

    % save to matrix
    save(fullfile(Paths.Summary, ERP_Filename), 'Targets', 'Standards', 'Chanlocs', 'Points')
else
    load(fullfile(Paths.Summary, ERP_Filename), 'Targets', 'Standards', 'Chanlocs', 'Points')
end

%%

Ch = 55;
ChanIndx = ismember( str2double({Chanlocs.labels}), Ch);


Diff = nan(numel(Participants), numel(Sessions), Points);

% plot grid of ERPs, target  & standard, like elias
figure('units','normalized','outerposition',[0 0 1 1])
t = linspace(Window(1), Window(2), Points);
for Indx_S = 1:numel(Sessions)
    subplot(3, 4, Indx_S)
    hold on
    T =  squeeze(nanmean(Targets(:, Indx_S, ChanIndx, :), 3));
    S = squeeze(nanmean(Standards(:, Indx_S, ChanIndx, :), 3));
    
    for Indx_P = 1:numel(Participants)
       T(Indx_P, :) = smooth(T(Indx_P, :), 100); 

      S(Indx_P, :) = smooth(S(Indx_P, :), 100); 
      Diff(Indx_P, Indx_S, :) =  T(Indx_P, :)- S(Indx_P, :);
    end
    
    plot(t, nanmean(T,1), ...
        'LineWidth', 2, 'Color', Format.Colors.Generic.Red)
    
    plot(t, nanmean(S,1), ...
        'LineWidth', 2, 'Color', Format.Colors.Generic.Dark1)
    title(SessionLabels{Indx_S})
    xlim([-.5, 1])
    xlabel('Time (s)')
    ylabel('Amplitude (miV)')
    TimeSeriesStats(cat(3, T, S), t, 200)
end
 NewLims = SetLims(3, 4, 'y');

 %%
 %%% plot Global Mean Field Power
figure('units','normalized','outerposition',[0 0 1 1])
t = linspace(Window(1), Window(2), Points);
for Indx_S = 1:numel(Sessions)
    subplot(3, 4, Indx_S)
    hold on
    T =  squeeze(Targets(:, Indx_S, :, :));
    S = squeeze(Standards(:, Indx_S, :, :));
    
    T = GMFP(T);
    S = GMFP(S);
    
    for Indx_P = 1:numel(Participants)
       T(Indx_P, :) = smooth(T(Indx_P, :), 100); 

      S(Indx_P, :) = smooth(S(Indx_P, :), 100); 
      Diff(Indx_P, Indx_S, :) =  T(Indx_P, :)- S(Indx_P, :);
    end
    
    plot(t, nanmean(T,1), ...
        'LineWidth', 2, 'Color', Format.Colors.Generic.Red)
    
    plot(t, nanmean(S,1), ...
        'LineWidth', 2, 'Color', Format.Colors.Generic.Dark1)
    title(SessionLabels{Indx_S})
    xlim([-.5, 1])
    xlabel('Time (s)')
    ylabel('Amplitude (miV)')
    TimeSeriesStats(cat(3, T, S), t, 200)
end
 NewLims = SetLims(3, 4, 'y');
 
 %%
 figure('units','normalized','outerposition',[0 0 1 .5])
 for Indx_S = 1:numel(Sessions)
     
     D = squeeze(Diff(:, Indx_S, :));
    subplot(1, numel(Sessions), Indx_S) 
      plot(t, nanmean(D,1), ...
        'LineWidth', 2, 'Color', Format.Colors.Generic.Dark1)
    title(SessionLabels{Indx_S})
    xlim([-.25, 1.5])
    xlabel('Time (s)')
    if Indx_S == 1
    ylabel('Amplitude (miV)')
    end
    TimeSeriesStats(D, t, 200)
 end
  NewLims = SetLims(1, numel(Sessions), 'y');
 
% identify P100, P200, P300 peaks, save amplitude to matrix


