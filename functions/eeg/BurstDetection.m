function Windows = BurstDetection(Data, MinAmp, MinP, x)
% Data is a single channel; ideally the envelope of theta.
% fs is the sampling rate
% MinAmp is the scaling factor for the amplitude. The minimum amplitude is
% calculated as the peak of the density distribution of the channel, times
% MinAmp. 
% MinP is the minimum duration of a burst in datapoints.
% x determines the resolution of the density function distribution; x =
% 0:.1:10; works pretty well for theta band.

pd = fitdist(Data', 'kernel');
y = pdf(pd, x);

[~, Indx]=max(y);
Peak = x(Indx);
Lim = Peak*MinAmp;

[Starts, Ends] = data2windows(Data, Lim);

Short = (Ends - Starts) < MinP;

Windows = [Starts; Ends]';
Windows(Short, :) = [];

