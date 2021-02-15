function PlotAllClusters(EEG, CompsPower, PlotComps, MinAmp, MinP, x, Format)


nComps = numel(PlotComps);
[nChannels, nPnts] = size(EEG.data);
t = linspace(0, nPnts/EEG.srate, nPnts);
Y_Gap = mean(std(EEG.data, 0, 2))*4;
Y_Shifts = flip(linspace(0, Y_Gap*nChannels, nChannels));
t_Indexes = 1:nPnts;

Colors = Format.Colormap.Rainbow;
MaxColor = size(Colors, 1);
Colors = Colors(round(linspace(1, MaxColor, nComps)), :);
    
figure('units','normalized','outerposition',[0 0 1 1])
PlotEEG(EEG.data, t, Y_Shifts, [.2 .2 .2], true)
hold on

for Indx_C = 1:nComps
    
    C = PlotComps(Indx_C);
        %%% select time points
    Windows = BurstDetection(CompsPower(C, :), MinAmp, MinP, x);
    Time_Indx = any(t_Indexes>=Windows(:, 1) & t_Indexes<=Windows(:, 2));
    
     %%% select channels involved in this component
    Weights = EEG.icawinv(:, C);
    [~, Origin] = max(abs(Weights));
    
    % flip if its one of those inverted component
    if Weights(Origin) < 0
        Weights = -Weights;
    end

    Weight_Half = Weights(Origin)/2;
    Chan_Indx = Weights < -Weight_Half | Weights >Weight_Half;
    
    
    % get data to plot
    Comp = nan(size(EEG.data));
    Comp(Chan_Indx, Time_Indx) = EEG.data(Chan_Indx, Time_Indx);
    
    PlotEEG(Comp, t, Y_Shifts, Colors(Indx_C, :), false)
    plot(t, Y_Shifts(Origin)+Comp(Origin, :), 'Color',  Colors(Indx_C, :), 'LineWidth', 2)
end


% plot events
EventTypes = unique({EEG.event.type});
EventColors = Format.Colormap.Rainbow;
MaxColor = size(EventColors, 1);
EventColors = EventColors(round(linspace(1, MaxColor, numel(EventTypes))), :);

for Indx_E = 1:numel(EEG.event)
    E = EEG.event(Indx_E);

    Color = EventColors(strcmp(EventTypes, E.type), :);
    Top = double(Y_Shifts(1))+double(Y_Shifts(1))*.1;
    plot([E.latency, E.latency]./EEG.srate, [0, Top], 'Color', Color)
    text(E.latency./EEG.srate, Top,  E.type)

end

xlim([80, 100])


%%%% plot legend
figure
hold on
for Indx_C = 1:nComps
    scatter(1, Indx_C, 40, Colors(Indx_C, :), 'filled')
    text(1, Indx_C, num2str( PlotComps(Indx_C)))
    
end

end


function PlotEEG(Data, t, Y_Shifts, Color, SetLims)

Data = Data + Y_Shifts';

plot(t, Data, 'Color', Color)

if SetLims
xlim([t(1), t(end)])
ylim([min(Data(:)), max(Data(:))])
end

end