function [HilbertPower, Phase] = HilbertBands(EEG, Bands, Type, PlotData)
% calculates hilbert power for EEG data in specified bands
% Bands is a struct, with fieldnames indicating band names, and a 1x2
% matrix indicating frequency limits.
% Type indicates whether output is a 'struct' or 'matrix'
% PlotData is optional, in case debugging and want to see whatup

BandNames = fieldnames(Bands);

% can select how data is spat out
switch Type
    case 'struct'
        HilbertPower = struct();
    case 'matrix'
        [TotChannels, Points] = size(EEG.data);
        HilbertPower = zeros(TotChannels, Points, numel(BandNames));
        Phase = HilbertPower;
end

for Indx_B = 1:numel(BandNames)  
    
    EEG_filt = pop_eegfiltnew(EEG, [],  Bands.(BandNames{Indx_B})(2));
    EEG_filt = pop_eegfiltnew(EEG_filt, Bands.(BandNames{Indx_B})(1),  []);
   
    
    if exist('PlotData', 'var') && PlotData
        % plot power spectrum
        [pxx, ~] = pwelch(EEG.data(11, :));
        [pxxF, fr] = pwelch(EEG_filt.data(11, :));
        figure
        plot(fr, log(pxx))
        hold on
        plot(fr, log(pxxF))
    
        % plot data in time
        eegplot(EEG.data, 'srate', EEG.srate, 'winlength', 30, ...
            'command', 'tmprej = TMPREJ', 'data2', EEG_filt.data)
    end
    
    switch Type
        case 'struct'
            Hilby = hilbert(EEG_filt.data')';
            HilbertPower.(BandNames{Indx_B}) = abs(Hilby);
            HilbertPower.([BandNames{Indx_B}, '_phase']) = angle(Hilby);
        case 'matrix'
            Hilby = hilbert(EEG_filt.data')';
            HilbertPower(:, :,Indx_B) = abs(Hilby);
            Phase(:, :, Indx_B) = angle(Hilby);
    end
end

