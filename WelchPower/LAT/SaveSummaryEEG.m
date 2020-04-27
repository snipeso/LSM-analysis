% script that gets a sinle value for delta, theta, alpha and beta for each
% participant at each session; specifically hotspot channels

clear
close all
clc

wpLAT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Scaling = 'none'; % either 'log', 'none', or 'norm'

% Computer tasks
Sessions = allSessions.Comp;
SessionLabels = allSessionLabels.Comp;
SessionsTitle = 'Classic';

% all beamer tasks
% Sessions = allSessions.LAT;
% SessionLabels = allSessionLabels.LAT;
% SessionsTitle = 'ProjectorAll';

% all beamer tasks
% Sessions = allSessions.Beam;
% SessionLabels = allSessionLabels.Beam;
% SessionsTitle = 'Soporific';

% Destination = fullfile(Paths.Analysis, 'Regression', 'SummaryData', [Task, SessionsTitle]); % for regression
Destination = fullfile(Paths.Analysis, 'Statistics', Task, 'Data'); % for statistics


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
    case 'norm'
        load(fullfile(Paths.wp, 'wPower', 'LAT_FFTnorm.mat'), 'normFFT')
        allFFT = normFFT;
    case 'none'
%         ChanIndx = 1:size(Chanlocs, 2);
        Scaling = '';
end
TitleTag = [Scaling, SessionsTitle];

PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);

saveFreqFields = fieldnames(saveFreqs);

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
            Matrix(Indx_P, Indx_S) = sum(nanmean(nanmean(Power, 3), 1))*FreqRes; % calculates the integral
            
        end
    end
    Filename = [Task, '_', saveFreqFields{Indx_F}, '_', TitleTag, '.mat'];
    save(fullfile(Destination, Filename), 'Matrix')
end



