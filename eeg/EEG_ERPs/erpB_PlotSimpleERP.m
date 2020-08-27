
clear
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Stimulus = 'Resp';
% Options: 'Tones' (from LAT), 'Alarm', 'Stim', 'Resp', 'RespISI'

Condition = 'Beam';
% Options: 'Beam', 'BL', 'SD'

Refresh = true;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Load_SimpleERP



%%% get indices
[~, PlotChannels] = intersect({Chanlocs.labels}, string(EEG_Channels.(PlotChannels)));
ERPWindow = Stop - Start;

% time arrays
t = linspace(Start, Stop, ERPWindow*newfs);
tPower = linspace(Start, Stop, ERPWindow*HilbertFS);

[~, StartPower] = min(abs(tPower -PowerWindow(1)));
[~, StopPower] = min(abs(tPower -PowerWindow(2)));



%%%%%%%%%%%%
%%% Plots
for Indx_Ch = 1:numel(PlotChannels)
    % plot ERP, with each participant in light color
    figure('units','normalized','outerposition',[0 0 .5 .5])
    PlotERP(t, allData, TriggerTime,  PlotChannels(Indx_Ch), BLPoints, 'Participants', Format.Colors.Participants)
    xlim(Xlims)
    title([Labels{Indx_Ch}, ' ', replace(TitleTag, '_', ' '), ' ERP'])
    set(gca, 'FontSize', 14, 'FontName', Format.FontName)
    ylabel('miV')
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, Labels{Indx_Ch}, '_SimpleERP.svg']))
    
    
    % plot ERP, delta, theta, beta etc..
    figure('units','normalized','outerposition',[0 0 .5 1])
    for Indx_B = 1:numel(BandNames)
        subplot(numel(BandNames), 1,  Indx_B)
        %         PlotERP(tPower, allPower.(BandNames{Indx_B}), TriggerTime, ...
        %             PlotChannels(Indx_Ch), 'Participants', Format.Colors.Participants)
        PlotERP(tPower, allPower.(BandNames{Indx_B}), TriggerTime, ...
            PlotChannels(Indx_Ch), [], 'Sessions',Format.Colors.([Task,Condition]))
        xlim(Xlims)
        title([Labels{Indx_Ch}, ' ', BandNames{Indx_B}, ' ', replace(TitleTag, '_', ' '),])
        set(gca, 'FontSize', 14, 'FontName', Format.FontName)
    end
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, Labels{Indx_Ch}, '_SessionsPower.svg']))
    
    
    % plot mean ERPs by session
    figure('units','normalized','outerposition',[0 0 .5 .5])
    PlotERP(t, allData, TriggerTime,  PlotChannels(Indx_Ch), BLPoints, 'Sessions', Format.Colors.([Task,Condition]))
    xlim(Xlims)
    title([Labels{Indx_Ch}, ' ', replace(TitleTag, '_', ' '), ' ERP by Session'])
    ylabel('miV')
    set(gca, 'FontSize', 14, 'FontName', Format.FontName)
    legend(SessionLabels)
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, Labels{Indx_Ch}, '_SessionsERP.svg']))
    
    
    % plot erps by ongoing frequency power quartiles
    Limits = [0:.2:1];
    for Indx_B = 1:numel(BandNames)
        
        Quantiles = struct();
        for Indx_P = 1:numel(Participants)
            for Indx_S = 1:numel(Sessions)
                tempData = allPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S});
                if isempty(tempData)
                    continue
                end
                Power = squeeze(nanmean(nanmean(tempData( PlotChannels(Indx_Ch), StartPower:StopPower, :), 2), 1));
                Edges = quantile(Power, Limits);
                Quantiles(Indx_P).(Sessions{Indx_S}) = discretize(Power, Edges);
            end
            
        end
        
        figure('units','normalized','outerposition',[0 0 .5 .5])
        Colors = flipud(gray(numel(Edges)));
        PlotERP(t, allData, TriggerTime,  PlotChannels(Indx_Ch), BLPoints, 'Custom', Colors(2:end, :), Quantiles)
        xlim(Xlims)
        title([ Labels{Indx_Ch}, ' ', replace(TitleTag, '_', ' '), ' based on ongoing ', BandNames{Indx_B}, ' power'])
        ylabel('miV')
        set(gca, 'FontSize', 14, 'FontName', Format.FontName)
        legend(split(cellstr(num2str(Limits(2:end)))))
        saveas(gcf,fullfile(Paths.Figures, [TitleTag, Labels{Indx_Ch}, '_', BandNames{Indx_B}, '_Power_OngoingFreq.svg']))
    end
    
end
% eventually, plot P200xongoing power, see if linearly correlated


% plot p200xphase, split by quartiles

