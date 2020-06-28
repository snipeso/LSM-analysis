
clear
clc
close all

run(fullfile(extractBefore(mfilename('fullpath'), 'statistics'), 'General_Parameters'))

% Options:
% - zscore or other corection
% - which tasks or sessions to use
% - parametric or non-parametric
% - correct for session or not (subtract session average)
% - correct for task or not?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'PVT', 'LAT'};

Measures = {'Delta'; 'Theta'; 'Alpha'; 'Beta';
    'miDuration'; 'miStart'; 'miTot';
    'meanRTs'; 'Hits'; 'Misses';
    'KSS'; 'Motivation'; 'Focused'; 'Effortful'};

Conditions = {'Classic', 'Soporific'};

SessionLabels = allSessionLabels.Basic; % TODO: eventually make this info saved in the matrices

Normalize = 'zscore';

Title = 'All Measures ';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

All_Measures_T = table();
Participant_Labels = repmat(Participants, 1, numel(SessionLabels))';
Session_Labels = reshape(repmat(SessionLabels, numel(Participants), 1), [], 1);

All_Measures_M = nan(numel(SessionLabels)*numel(Participants)*numel(Tasks)*numel(Conditions), numel(Measures));
% assemble the data as a matrix of every measure
% PVT - Classic
% PVT - Soporific
% LAT - Classic
% LAT - Soporific
for Indx_M = 1:numel(Measures)
    T = table();
    for Indx_T = 1:numel(Tasks)
        
        for Indx_C = 1:numel(Conditions)
            T_temp = table();
            DataPath = fullfile(Paths.Analysis, 'statistics', 'Data', Tasks{Indx_T}, ...
                [Tasks{Indx_T}, '_', Measures{Indx_M}, '_', Conditions{Indx_C}, '.mat']);
            load(DataPath, 'Matrix')
            
            % assemble into a section of table
            T_temp.Participant = Participant_Labels;
            T_temp.Session = Session_Labels;
            T_temp.Task = cellstr(repmat(Tasks{Indx_T}, numel(Participant_Labels), 1));
            T_temp.Condition = cellstr(repmat(Conditions{Indx_C}, numel(Participant_Labels), 1));
            T_temp.(Measures{Indx_M}) = Matrix(:);
            
            % append to final table
            T = [T; T_temp];
        end
    end
    

    
    
    All_Measures_T.Participant = T.Participant; % NOTE: this is just a mindless way of making sure the labels are correct
    All_Measures_T.Session = T.Session;
    All_Measures_T.Task = T.Task;
    All_Measures_T.Condition = T.Condition;
    
    AllData =  T.(Measures{Indx_M});
        % z-score
    switch Normalize
        case 'zscore'
            for Indx_P = 1:numel(Participants)
                Indexes =  strcmp(All_Measures_T.Participant, Participants{Indx_P});
                
                All = zscore(AllData(Indexes));
                AllData(Indexes) = All;
            end
    end
    
    
    
    All_Measures_T.(Measures{Indx_M}) =AllData;
    All_Measures_M(:, Indx_M) =  AllData;
end




[R,P] = corrcoef( All_Measures_M, 'Rows','pairwise');
figure('units','normalized','outerposition',[0 0 1 1])
PlotCorr(R, [], Measures)
title([Title, ' R values of all parameters'])

figure('units','normalized','outerposition',[0 0 1 1])
PlotCorr(R, P, Measures)
title([Title, ' R values of all parameters, 0.05 corrected'])

figure('units','normalized','outerposition',[0 0 1 1])
[~,h] = fdr(P, 0.05);
PlotCorr(R, h, Measures)
title([Title, ' R values of all parameters, fdr corrected'])
