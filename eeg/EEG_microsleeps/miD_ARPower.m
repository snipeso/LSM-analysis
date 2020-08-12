clear
clc
close all

Microsleeps_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false;
Scaling = 'zscore';
Tasks = {'PVT' , 'LAT'};
Sessions = {'Baseline', 'Session1', 'Session2'};
Conditions = {'Beam', 'Comp'};
Title = 'AllTasks';
PlotLims = [1 30];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TitleTag = [Title,'_', Scaling];

FFT_Path = fullfile(Paths.Summary, [Title, '_Microsleeps_arFFT.mat']);

% if not summary or refresh, reload data from Jelena's files
if ~exist(FFT_Path, 'file') || Refresh
    
    disp(['*************Creating ', Title, '******************'])
    
    allFFT = struct('FFT', [], 'Filename', []);
    Categories = []; % Rows: participant, task, session, condition
    IndxFFT = 1;
    for Indx_T = 1:numel(Tasks)
        arPath = fullfile(Paths.Preprocessed, 'Microsleeps', 'MAT', Tasks{Indx_T}, 'Jelena');
        Files = ls(arPath);
        Files(~contains(string(Files), '.mat'), :) = [];
        
        for Indx_F = 1:size(Files, 1)
            File =  Files(Indx_F, :);
            load(fullfile(arPath,File), 'S')
            FFT = cat(3, S.power_O1M2, S.power_O2M1, S.power_E1E2);
            FFT = permute(FFT, [3,1,2]);
            
            allFFT(IndxFFT).FFT = FFT;
            allFFT(IndxFFT).Microsleeps =  [zeros(22, 1); S.MSE_scoring; zeros(22, 1)];
            allFFT(IndxFFT).Filename = File;
            
            Labels =  split(File, '_');
            
            if contains(Labels{3}, 'Comp')
                Condition = 'Comp';
            elseif contains(Labels{3}, 'Beam')
                Condition = 'Beam';
            else
                Condition = '';
            end
            
            Session = extractBefore(Labels{3}, Condition);
            
            Categories = cat(2, Categories, [Labels(1); Tasks(Indx_T); {Session}; {Condition}]);
            
            IndxFFT = IndxFFT + 1;
            
        end
    end
    Freqs = S.ff;
    save(FFT_Path, 'allFFT', 'Categories', 'Freqs', '-v7.3')
else
    load(FFT_Path, 'allFFT', 'Categories', 'Freqs')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% restructure data and apply scaling

switch Scaling
    case 'log'
        for Indx_F = 1:size(allFFT, 2)
            allFFT(Indx_F).FFT = log(allFFT(Indx_F).FFT);
        end
        [PowerStruct, Scores] = Restructure(allFFT, Categories, Sessions, Participants);
        YLabel = 'Power Density (log)';
    
    case 'zscore'
     [PowerStruct, Scores] = Restructure(allFFT, Categories, Sessions, Participants);
        PowerStruct = ZScoreFFT(PowerStruct);
        YLabel = 'Power Density (zscored)';
        otherwise
       [PowerStruct, Scores] = Restructure(allFFT, Categories, Sessions, Participants);
        YLabel = 'Power Density';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get limits per participant

Quantiles_Big = nan(numel(Participants), numel(Sessions), 2);
Quantiles_Small =  nan(numel(Participants), numel(Sessions), 2);

PlotFreqIndx =  dsearchn(Freqs', PlotLims');

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
       
        A =  PowerStruct(Indx_P).(Sessions{Indx_S})(1, PlotFreqIndx(1): PlotFreqIndx(2), :);
        A = A(:); % pool datasets
        Quantiles_Big(Indx_P, Indx_S, :) =  [quantile(A(:), .01),  quantile(A(:), .99)];
        Quantiles_Small(Indx_P, Indx_S, :) =  [quantile(A(:), .05),  quantile(A(:), .95)];
        
    end
end

YLims_Big = squeeze(nanmean(nanmean(Quantiles_Big(:, :, :), 2),1));
YLims_Small = squeeze(nanmean(nanmean(Quantiles_Small(:, :, :), 2),1));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot same session in microsleep vs out microsleep from O channels

Microsleeps = [];
EE = [];

ALLSession_mi = nan(numel(Freqs), numel(Sessions));
ALLSession_EE = nan(numel(Freqs), numel(Sessions));
ALLSession_All = nan(numel(Freqs), numel(Sessions));

for Indx_S = 1:numel(Sessions)
    Session_mi = [];
    Session_EE = [];
    Session_All = [];
    
    for Indx_P = 1:numel(Participants)
        
        all=  PowerStruct(Indx_P).(Sessions{Indx_S});
        all = squeeze(nanmean(all(1:2, :, :), 1)); % get average of occipital channels
        
        
        % get all epochs
        mi_FFT = all(:, logical(Scores(Indx_P).(Sessions{Indx_S})));
        EE_FFT = all(:, ~logical(Scores(Indx_P).(Sessions{Indx_S})));
        
        % average hotspot channel and then epochs
        mi_FFT = squeeze(nanmean(mi_FFT(:, :), 2))';
        EE_FFT = squeeze(nanmean(EE_FFT( :, :), 2))';
        all = squeeze(nanmean(all(:, :), 2))';
        
        
        % save session separately
        Session_mi = cat(1, Session_mi, mi_FFT); 
        Session_EE = cat(1, Session_EE, EE_FFT);
        Session_All = cat(1, Session_All, all);
        
    end

    % plot session microsleeps, using session averages per participant
    PlotMicrosleeps(Session_mi', Session_EE', Freqs, YLims_Big, YLabel, Format)
    title([Sessions{Indx_S}, ' Microsleep Power ', replace(TitleTag, '_', ' ')])
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_', Sessions{Indx_S}, '_MicrosleepPower.svg']))
    
    % save averages together
     Microsleeps = cat(1, Microsleeps, Session_mi);
     EE = cat(1, EE, Session_EE);
     
    ALLSession_mi(:, Indx_S) =  nanmean( Session_mi, 1);
    ALLSession_EE(:, Indx_S) = nanmean(Session_EE, 1);
    ALLSession_All(:, Indx_S) = nanmean(Session_All, 1);
    
end

PlotMicrosleeps(Microsleeps', EE', Freqs, YLims_Big, YLabel, Format)
saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_MicrosleepARPower.svg']))

PlotPowerSpectrumDiff(ALLSession_mi, ALLSession_All, Freqs, YLims_Small, YLabel, Sessions, ...
    Format, ['Microsleeps by Session ', replace(TitleTag, '_', ' ')])
saveas(gcf,fullfile(Paths.Figures, [ TitleTag, '_MicrosleepARPower_Means.svg']))



% plot time x freq for 1-5, 5-10 and 10-15s microsleeps, also as bands




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [PowerStruct, Scores] = Restructure(allFFT, Categories, Sessions, Participants)
% results in a huge matrix of participant x session x channel x frequency x
% epoch

PowerStruct = struct();
Scores = struct();

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)

        FileIndx = strcmp(Categories(3, :), Sessions{Indx_S}) & ...
            strcmp(Categories(1, :), Participants{Indx_P});
        if nnz(FileIndx) > 1
            warning(['**************Concatenating files for ', Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])

            PowerStruct(Indx_P).(Sessions{Indx_S}) =  cat(3, allFFT(FileIndx).FFT);
             Scores(Indx_P).(Sessions{Indx_S}) = allFFT(FileIndx).Microsleeps;
        elseif nnz(FileIndx) < 1
            warning(['**************Could not find ', Participants{Indx_P}, ' ',  Sessions{Indx_S}, '*************' ])
            continue
        else
            
        PowerStruct(Indx_P).(Sessions{Indx_S}) = allFFT(FileIndx).FFT;
        Scores(Indx_P).(Sessions{Indx_S}) = allFFT(FileIndx).Microsleeps;
        end

    end
end
end