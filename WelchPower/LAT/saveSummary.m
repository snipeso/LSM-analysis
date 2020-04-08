clear
close all
clc

wpLAT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Destination = fullfile(Paths.Analysis, 'Regression', 'SummaryData', 'LAT');

Scaling = 'log'; % either 'log' or 'norm'

% Sessions = allSessions.Comp;
% SessionLabels = allSessionLabels.Comp;
% SessionsTitle = 'Comp';

Sessions = allSessions.LAT;
SessionLabels = allSessionLabels.LAT;
SessionsTitle = 'Beam';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

saveFreqs = struct();
saveFreqs.Delta = [1 4];
saveFreqs.Theta = [4.5 7.5];
saveFreqs.Alpha = [8.5 12.5];
saveFreqs.Beta = [14 25];

plotChannels = [3:7, 9:13, 15, 16, 18:20, 24, 106, 111, 112, 117, 118, 123, 124]; % hotspot
ChanIndx = ismember( str2double({Chanlocs.labels}), plotChannels);

switch Scaling
    case 'log'
        for Indx_F = 1:size(allFFT, 2)
            allFFT(Indx_F).FFT = log(allFFT(Indx_F).FFT);
        end
        YLabel = 'Power Density';
        YLims = [-2.5, 0.5];
        YLimsInd = [-4, 4];
    case 'norm'
        load(fullfile(Paths.wp, 'wPower', 'LAT_FFTnorm.mat'), 'normFFT')
        allFFT = normFFT;
        YLabel = '% Change from Pre';
        YLims = [-50, 100];
        YLimsInd = [-100, 400];
end
TitleTag = [Scaling, '_', SessionsTitle];

PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);

saveFreqFields = fieldnames(saveFreqs);

for Indx_F = 1:numel(saveFreqFields)
    FreqLims = saveFreqs.(saveFreqFields{Indx_F});
    FreqIndx =  dsearchn(Freqs', FreqLims');
    
    Matrix = nan(numel(Participants), numel(Sessions));
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            Power = PowerStruct(Indx_P).(Sessions{Indx_S})(ChanIndx, FreqIndx(1):FreqIndx(2), :);
            Matrix(Indx_P, Indx_S) = sum(nanmean(nanmean(Power, 3), 1));
            
        end
    end
    Filename = [Task, '_', saveFreqFields{Indx_F}, '_', TitleTag, '.mat'];
    save(fullfile(Destination, Filename), 'Matrix')
end



