
%%% get data
LoadWelchData
close all

% plot for each recording the peak frequency

PlotFreq = 1:20;
FreqsIndx =  dsearchn( Freqs', PlotFreq');

ChanIndx = ismember( str2double({Chanlocs.labels}), EEG_Channels.Hotspot);
NotChanIndx =  ~ismember( str2double({Chanlocs.labels}), EEG_Channels.Hotspot); % not hotspot
Title = 'HotSpot';
PaleColors = flipud(palejet(numel(PlotFreq)));
Colors = flipud(jet(numel(PlotFreq)));

Delta = dsearchn(PlotFreq', round(saveFreqs.Delta)');
Theta= dsearchn(PlotFreq', round(saveFreqs.Theta)');
Alpha= dsearchn(PlotFreq', round(saveFreqs.Alpha)');
Beta = dsearchn(PlotFreq', round(saveFreqs.Beta)');

TallyColors = Colors([Delta(1), Theta(2), Alpha(2), Beta(2)], :);

for Indx_H = 1
    if Indx_H == 1
        finalChanIndx = ChanIndx;
        Title =  'HotSpot';
    else
        finalChanIndx = NotChanIndx;
        Title =  'Not HotSpot';
    end
    
    F1 = figure( 'units','normalized','outerposition',[0 0 1 1]);
    F2 = figure( 'units','normalized','outerposition',[0 0 1 .5]);
    
    for Indx_P = 1:numel(Participants)
        Tally = zeros(numel(Sessions), size(TallyColors, 1));
        for Indx_S = 1:numel(Sessions)
            if isempty(PowerStruct(Indx_P).(Sessions{Indx_S}))
                continue
            end
            
            A = PowerStruct(Indx_P).(Sessions{Indx_S});
            A = squeeze(nanmean(A(finalChanIndx, FreqsIndx, :), 1));
            
            figure(F1)
            subplot(numel(Participants), numel(Sessions), numel(Sessions) * (Indx_P - 1) + Indx_S )
            hold on
            for Indx_F = 1:numel(FreqsIndx)
%                 A(Indx_F, :) = ( A(Indx_F, :) - nanmean( A(Indx_F, :)))./nanstd( A(Indx_F, :));
                scatter(1:size(A, 2), A(Indx_F, :), 10, PaleColors(Indx_F, :), 'filled')
                ylim([0 10])
            end
            [Max, Indx] = max(A);
            scatter(1:size(A, 2), Max, 10, Colors(Indx, :), 'filled', 'MarkerEdgeColor', 'k')
            
            title([Participants{Indx_P}, ' ', Title, ' ', Sessions{Indx_S}])
            
            Tally(Indx_S, 1) = nnz(Indx<=Delta(2));
            Tally(Indx_S, 2) = nnz(Indx>Theta(1) & Indx<=Theta(2));
            Tally(Indx_S, 3) = nnz(Indx>Alpha(1) & Indx<=Alpha(2));
            Tally(Indx_S, 4) = nnz(Indx>Beta(1) & Indx<=Beta(2));
            
        end
        figure(F2)
        subplot(1, numel(Participants), Indx_P)
        Tally = 100.*(Tally./sum(Tally, 2));
        PlotStacks(Tally, TallyColors)
        
    end
    figure(F1)
    legend(string(num2cell(PlotFreq)))
end
