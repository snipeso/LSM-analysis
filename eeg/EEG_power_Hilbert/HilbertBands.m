function [HilbertPower, Phase] = HilbertBands(EEG, Bands, BandNames, Type)

switch Type
    case 'struct'
        HilbertPower = struct();
    case 'matrix'
        [TotChannels, Points] = size(EEG.data);
        HilbertPower = zeros(TotChannels, Points, numel(BandNames));
        Phase = HilbertPower;
end

for Indx_B = 1:numel(BandNames)
    EEG_filt = pop_eegfiltnew(EEG, Bands(Indx_B, 1), Bands(Indx_B, 2));
    
    %     [pxx, ~] = pwelch(EEG.data(11, :));
    %     [pxxF, fr] = pwelch(EEG_filt.data(11, :));
    %     figure
    %     plot(fr, log(pxx))
    %     hold on
    %     plot(fr, log(pxxF))
    %
    %     eegplot(EEG.data, 'srate', EEG.srate, 'winlength', 30, ...
    %         'command', 'tmprej = TMPREJ', 'data2', EEG_filt.data)
    
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

