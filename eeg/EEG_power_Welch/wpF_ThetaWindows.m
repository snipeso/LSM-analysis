
%%% get data
% LoadWelchData
% close all

% plot for each recording the peak frequency

PlotFreq = 4:12;
FreqsIndx =  dsearchn( Freqs', PlotFreq');

ChanIndx = ismember( str2double({Chanlocs.labels}), EEG_Channels.Hotspot);
NotChanIndx =  ~ismember( str2double({Chanlocs.labels}), EEG_Channels.Hotspot); % not hotspot
Title = 'HotSpot';
PaleColors = flipud(palejet(numel(PlotFreq)));
Colors = flipud(jet(numel(PlotFreq)));

for Indx_H = 1
    if Indx_H == 1
        finalChanIndx = ChanIndx;
        Title =  'HotSpot';
    else
        finalChanIndx = NotChanIndx;
        Title =  'Not HotSpot';
    end
    
    F1 = figure( 'units','normalized','outerposition',[0 0 1 1]);
     F2 = figure( 'units','normalized','outerposition',[0 0 1 1]);
    
    for Indx_P = 1:numel(Participants)
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
                A(Indx_F, :) = ( A(Indx_F, :) - nanmean( A(Indx_F, :)))./nanstd( A(Indx_F, :));
                scatter(1:size(A, 2), A(Indx_F, :), 10, PaleColors(Indx_F, :), 'filled')
                
            end
            [Max, Indx] = max(A);
            scatter(1:size(A, 2), Max, 10, Colors(Indx, :), 'filled', 'MarkerEdgeColor', 'k')
            
            title([Participants{Indx_P}, ' ', Title, ' ', Sessions{Indx_S}])
            
            figure(F2)
            subplot(numel(Participants), numel(Sessions), numel(Sessions) * (Indx_P - 1) + Indx_S )
            histogram(Indx, 'BinLimits', [1 10], 'NumBins',numel(PlotFreq))
            xticklabels(PlotFreq)
        end
        
    end
    figure(F1)
   legend(string(num2cell(PlotFreq)))
end
