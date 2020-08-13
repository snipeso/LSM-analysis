
% Load_Tones

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PowerWindow = [-1.5, .1];
TimePoints = [0, .2 .26, .33, .44, .8];
PlotChannels = EEG_Channels.Hotspot; % eventually find a more accurate set of channels?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TitleTag = [Task '_', Title, '_Tones'];

% create average ERP and Power for everyone at all channels
ERPWindow = round((Stop - Start)*newfs);
PowerWindow =  round((Stop - Start)*HilbertFS);
allERP = nan(numel(Participants), size(Chanlocs, 2), ERPWindow); % tbsqueezed
allPowerERP = nan(numel(Participants), size(Chanlocs, 2), PowerWindow, numel(BandNames));

for Indx_P =1:numel(Participants)
    
    %%% average all sessions for each participant
    sERP = [];
    sPowerERP = [];
    for Indx_S = 1:numel(Sessions)
        Data = allData(Indx_P).(Sessions{Indx_S});
        if isempty(Data)
            continue
        end
        
        % restructure power so that it is ch x t x band x trial
        Power = [];
        for Indx_B = 1:numel(BandNames)
            Power = cat(4, Power, allPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}));
        end
        Power = permute(Power, [1 2 4 3]);
        
        sERP = cat(3, sERP, Data);
        sPowerERP = cat(4, sPowerERP, Power);
        
    end
    
    % save to matrix
    allERP(Indx_P, :, :) = squeeze(nanmean(sERP, 3));
    allPowerERP(Indx_P, :, :, :) = squeeze(nanmean(sPowerERP, 4));
    
end

% average to single ERP
ERP = squeeze(nanmean(allERP, 1));
PowerERP =  squeeze(nanmean(allPowerERP, 1));

% plot stills
Points = round((TimePoints-Start)*newfs);
Time = string(TimePoints*1000);
Unit = repmat("ms", 1, numel(Time));
Titles = append(Time, Unit);

PlotTopoTimePoints(ERP, Chanlocs, Points, Titles, Format)

for Indx_B = 1:numel(BandNames)
    Band = repmat([BandNames{Indx_B}, ' '], 1, numel(Time));
    Titles = append(Band, Time, Unit);
    
    PlotTopoTimePoints(squeeze(PowerERP(:, :, Indx_B)), Chanlocs, Points, Titles, Format)
end

% plot gif of ERP


% plot gif of power