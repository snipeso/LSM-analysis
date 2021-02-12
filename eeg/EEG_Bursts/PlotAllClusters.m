function PlotAllClusters(EEG, CompsPower, MinAmp, MinP, x)



[nComps, nPnts] = size(CompsPower);
t = linspace(0, nPnts/EEG.srate, nPnts);
Y_Gap = mean(std(EEG.data, 0, 2))*4;
    
figure('units','normalized','outerposition',[0 0 1 1])
PlotEEG(EEG.data, t, Y_Gap, [.2 .2 .2])

for Indx_C = 1:nComps
    
    
    
end














end


function PlotEEG(Data, t, Y_Gap, Color)

Channels = size(Data, 1);
Y_Shift = linspace(0, Y_Gap*Channels, Channels);

Data = Data + Y_Shift';

plot(t, Data, 'Color', Color)

xlim([t(1), t(end)])
ylim([min(Data(:)), max(Data(:))])



end