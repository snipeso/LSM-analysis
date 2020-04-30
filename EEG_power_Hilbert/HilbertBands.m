function Hilbert = HilbertBands(EEG, Bands, BandNames)

Hilbert = struct();

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
    
    Hilby = hilbert(EEG_filt.data')';
    Hilbert.(BandNames{Indx_B}) = abs(Hilby);
    Hilbert.([BandNames{Indx_B}, '_phase']) = angle(Hilby);
    
%     t = linspace(0, EEG.pnts/EEG.srate, EEG.pnts);
%     figure
%     plot(t, mat2gray(EEG.data(11, :)))
%     hold on
%     plot(t, mat2gray(EEG_filt.data(11, :)))
%     plot(t, mat2gray(Hilbert.(BandNames{Indx_B}) (11, :)))
%     plot(t, mat2gray(Hilbert.([BandNames{Indx_B}, '_phase'])(11, :)))
%     legend({'raw', 'filt', 'power', 'phase'})
%     
%     
%     A = 1;
    
end

