clear
clc
close all

wpLAT_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Scaling = 'none'; % either 'log' or 'norm'

Sessions = allSessions.Comp;
SessionLabels = allSessionLabels.Comp;
SessionsTitle = 'Comp';

% Sessions = allSessions.LAT;
% SessionLabels = allSessionLabels.LAT;
% SessionsTitle = 'Beam';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch Scaling
    case 'log'
        for Indx_F = 1:size(allFFT, 2)
            allFFT(Indx_F).FFT = log(allFFT(Indx_F).FFT + 1);
        end
        YLabel = 'Power Density of Log';
        
    case 'norm'
        load(fullfile(Paths.wp, 'wPower', 'LAT_FFTnorm.mat'), 'normFFT')
        allFFT = normFFT;
        YLabel = '% Change from Pre';
    case 'none'
        YLabel = 'Power Density';
        
end
TitleTag = join({Task, Scaling, SessionsTitle}, '_');

PowerStruct = GetPowerStruct(allFFT, Categories, Sessions, Participants);

