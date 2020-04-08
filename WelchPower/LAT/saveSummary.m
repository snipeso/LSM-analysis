clear
close all
clc

wpLAT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
TitleTag = [Scaling, SessionsTitle];

PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);

saveFreqFields = getfield(saveFreqs);

for Indx_F = 1:numel(saveFreqFields)
    FreqIndx =  dsearchn( Freqs', plotFreqs');
    
    Matrix = nan(numel(Participants), numel(Sessions));
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            
        end
    end
    Filename = [];
    save(fullfile(Destination, Filename), Matrix)
end



