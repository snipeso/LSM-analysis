function PeakComparison(Matrix, FreqRange, Freqs, SessionLabels, Format)
% Matrix is participant x "session" x freqs

[nParticipants, nSessions, ~] = size(Matrix);
Peaks = nan(nParticipants, nSessions);

FreqRange =  dsearchn( Freqs', FreqRange');
Freqs = Freqs(FreqRange(1):FreqRange(2));
for Indx_P = 1:nParticipants
   for Indx_S = 1:nSessions
    Spectrum = squeeze(Matrix(Indx_P, Indx_S, FreqRange(1):FreqRange(2)));
    Spectrum = Spectrum - (min(Spectrum(:))); % shift so all values are positive
    [pks, locs] = findpeaks(Spectrum, Freqs);
    
    if numel(pks)<1
         Peaks(Indx_P, Indx_S) = nan;
    else
    [~, Indx] = max(pks);
    Peaks(Indx_P, Indx_S) = locs(Indx);
    end
   end
end

PlotConfettiSpaghetti(Peaks, SessionLabels, [], [], [], Format, true)
ylabel('Theta Peak Frequency')