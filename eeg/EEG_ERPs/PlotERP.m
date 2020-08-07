function PlotERP(t, Data, Trigger, Channels, Dimention, Format)


Sessions = fieldnames(Data);
Participants = size(Data, 2);
Points = size(Data(1).(Sessions{1}), 2);

AllERPs = [];
hold on
for Indx_S = 1:numel(Sessions)
    for Indx_P = 1:Participants
        
        tempData = Data(Indx_P).(Sessions{Indx_S});
        if isempty(tempData)
            continue
        end
        switch Dimention
            case 'Participants'
                ERP = nanmean(nanmean(tempData(Channels, :, :), 1), 3);
                
                
                plot(t, ERP, 'Color', Format.Colors.Participants(Indx_P, :), 'LineWidth', 2)
        end
        
        
        AllERPs = cat(1, AllERPs, ERP);
        
    end
end

ERP = nanmean(AllERPs, 1); %CHECK
plot(t, ERP, 'Color', 'k', 'LineWidth', 3)
set(gca, 'FontName', Format.FontName)
plot([Trigger, Trigger], [min(AllERPs(:)), max(AllERPs(:))], 'Color', [.5 .5 .5])
xlabel('Time (s)')
ylim( [min(AllERPs(:)), max(AllERPs(:))])