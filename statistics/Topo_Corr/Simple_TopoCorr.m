

clear
clc
close all

topo_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Normalization = 'zscoreP'; %'zscoreS&P' 'zscoreP', 'none'

Condition = 'RRT';

Topos = struct();
Topos.Power = {'Theta'}; % {'Delta', 'Theta', 'Alpha', 'Beta'}
Topos.Power = {'Delta', 'Theta', 'Alpha', 'Beta'};
Topos.PowerPeaks = {'Intercept', 'Amplitude', 'FWHM'};

Values = struct();
% Values.Questionnaires = {'KSS',  'WakeDifficulty', 'FixatingDifficulty'};
Values.Questionnaires = {'KSS'};
% Values.Questionnaires = {'KSS', 'WakeDifficulty', 'Difficulty', 'FixatingDifficulty', ...
%     'Alertness',  'Focus', 'Motivation', ...
%     'PhysicEnergy', 'EmotionEnergy', 'SpiritEnergy',  'PsychEnergy',  ...
%    'Mood',    'Happiness', 'Anger', ...
%     'Sadness',  'Fear', 'Stress', 'Tolerance',  'Other Pain'}; % extras:  'Enjoyment',  'Relxation',  'Hunger',  'Thirst',


% Tasks = {'Oddball', 'Fixation'};
Tasks = Format.Tasks.(Condition);

CLimits = [-.6, .6];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TitleTag = strjoin({'SimpleTopoCorr', Normalization, Condition, Tasks{1:end}}, '_');


Paths.Results = fullfile(Paths.Results, 'TopoCorr');
if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

TopoMeasures = fieldnames(Topos);
ValueMeasures = fieldnames(Values);

for Indx_TM = 1:numel(TopoMeasures)
    Measure = TopoMeasures{Indx_TM};
    TopoBands = Topos.(Measure);
    for Indx_TB = 1:numel(TopoBands)
        for Indx_T = 1:numel(Tasks)
            Task = Tasks{Indx_T};
            % load topographies (p x s x ch)
            Filename_Topo = strjoin({Measure, Condition, Task, [TopoBands{Indx_TB}, '.mat']}, '_');
            load(fullfile(Paths.Topos, Measure, Filename_Topo), ...
                'Topo', 'Chanlocs', 'SessionLabels')
            
            % apply normalization
            switch Normalization
                case 'zscoreS&P' % ???
                    for Indx_P = 1:numel(Participants)
                        for Indx_S = 1:numel(SessionLabels)
                            T = Topo(Indx_P, Indx_S, :);
                            Mean = nanmean(T(:));
                            STD = nanstd(T(:));
                            Topo(Indx_P, Indx_S, :) = (T-Mean)./STD;
                        end
                    end
                case 'zscoreP'
                    for Indx_P = 1:numel(Participants)
                        T = Topo(Indx_P, :, :);
                        Mean = nanmean(T(:));
                        STD = nanstd(T(:));
                        Topo(Indx_P, :, :) = (T-Mean)./STD;
                    end
            end
            
            
            for Indx_VM = 1:numel(ValueMeasures)
                ValueTypes = Values.(ValueMeasures{Indx_VM});
                for Indx_VT = 1:numel(ValueTypes)
                    
                    % load matrix of values to compare (p x s)
                    Filename_Value = strjoin({ValueMeasures{Indx_VM}, ...
                        Condition, Task, [ValueTypes{Indx_VT}, '.mat']}, '_');
                    load(fullfile(Paths.Stats, ValueMeasures{Indx_VM}, Filename_Value), ...
                        'Matrix')
                    
                    % normalize values
                    switch Normalization
                        case 'zscoreS&P'
                            for Indx_P = 1:numel(Participants)
                                V = Matrix(Indx_P, :,:);
                                Mean = nanmean(V(:));
                                STD = nanstd(V(:));
                                Matrix(Indx_P, :, :) = (V-Mean)./STD;
                            end
                            Means = nanmean(Matrix, 1);
                            Matrix = Matrix-Means;
                        case 'zscoreP'
                            for Indx_P = 1:numel(Participants)
                                V = Matrix(Indx_P, :,:);
                                Mean = nanmean(V(:));
                                STD = nanstd(V(:));
                                Matrix(Indx_P, :, :) = (V-Mean)./STD;
                            end
                    end
                    
                    
                    % get correlation
                    [TopoR, TopoP] = simpleTopoCorr(Topo, Matrix);
                    [~, h] = fdr(TopoP, .05);
                    figure('units','normalized','outerposition',[0 0 .15 .3])
                    Indexes = 1:numel(Chanlocs);
                    topoplot(TopoR, Chanlocs, 'maplimits', CLimits, ...
                        'style', 'map', 'headrad', 'rim', 'gridscale', Format.TopoRes, ...
                        'emarker2', {Indexes(logical(h)), 'o', 'w', 3, .01});
                    title(strjoin({ValueTypes{Indx_VT}, 'vs', TopoBands{Indx_TB}, Task, Normalization}, ' '))
                    set(gca, 'FontSize', 12, 'FontName', Format.FontName)
                    colormap(Format.Colormap.Divergent)
                    colorbar
                    
                    saveas(gcf, fullfile(Paths.Results, ...
                        strjoin({ValueTypes{Indx_VT}, 'vs', TopoBands{Indx_TB}, Task, [Normalization, '.svg']}, '_')))
                end
                
            end
        end
    end
end



% loop through values

% apply normalization if requested

% get topoCorr

% plot topoCorr

