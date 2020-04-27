[Movie, Colormap] = eegmovie(EEG.data(:, Event),EEG.srate, Chanlocs)

seemovie()

Event = [40*EEG.srate:42*EEG.srate];
Data = EEG_SD.data(:, Event);
Max = max(abs(Data(:)));
YLims = [-Max, Max];

[Movie, Colormap] = eegmovie(Data,EEG.srate, EEG.chanlocs, 'minmax', YLims, ...
    'topoplotopt', {'style', 'map', 'headrad', 'rim',  'gridscale', 150, 'colormap', rdbu});


Event = [702*EEG_SD.srate:10:705*EEG_SD.srate];
Data = Hilbert.theta(:, Event);
% Max = max(abs(Data(:)));
% YLims = [min(Data(:)), max(Data(:))];
YLims = [0, 25];
figure
[MovieTheta, ColormapTheta] = eegmovie(Data,EEG_SD.srate/10, EEG_SD.chanlocs, 'minmax', YLims, ...
    'topoplotopt', {'style', 'map', 'headrad', 'rim',  'gridscale', 150, 'colormap', magma});


figure
seemovie(MovieTheta, 100, ColormapTheta)



Event = [381*EEG.srate:10:387*EEG.srate];
Data = Hilbert.alpha(:, Event);
Max = max(abs(Data(:)));
% YLims = [min(Data(:)), max(Data(:))];
YLims = [0, 25];
figure
[MovieAlpha, ColormapAlpha] = eegmovie(Data, EEG.srate/10, EEG.chanlocs, 'minmax', YLims, ...
    'topoplotopt', {'style', 'map', 'headrad', 'rim',  'gridscale', 150, 'colormap', magma});



figure
seemovie(MovieAlpha, 100, ColormapAlpha)