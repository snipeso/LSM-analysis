function PlotPooledERP(t, Data, Trigger, Channels, Dimention, Colors, Category)


Sessions = fieldnames(Data);
Participants = size(Data, 2);
Points = size(Data(1).(Sessions{1}), 2);

AllERPs = [];
hold on

if strcmp(Dimention, 'Custom')
    Unique_Categories = unique(Category(1).(Sessions{1}));
    %     CustomERPs = nan(Participants, Points, numel(Unique_Categories));
    CustomERPs = struct();
end


Min = nan;
Max = nan;

for Indx_S = 1:numel(Sessions)
    if strcmp(Dimention, 'Sessions')
        SessionERPs = [];
    end
    
    for Indx_P = 1:Participants
        
        tempData = Data(Indx_P).(Sessions{Indx_S});
        if isempty(tempData)
            continue
        end
        switch Dimention
            case 'Participants'
                ERP = nanmean(tempData(Channels, :, :), 1);
                plot(t, nanmean(ERP, 3), 'Color', Colors(Indx_P, :), 'LineWidth', 2)
            case 'Sessions'
                ERP = squeeze(nanmean(tempData(Channels, :, :), 1));
                SessionERPs = cat(2, SessionERPs, ERP);
                Min = min(Min, min(ERP(:)));
                Max = max(Max, max(ERP(:)));
            case 'Custom'
                
                for Indx_C = 1:numel(Unique_Categories)
                    Trials =  Category(Indx_P).(Sessions{Indx_S})== Unique_Categories(Indx_C);
                    ERP = squeeze(nanmean(tempData(Channels, :,Trials), 1));
                    %                     CustomERPs(Indx_P, :, Indx_C) = ERP; %TODO: try cat all stimuli, so ERP is smoother
                    Cat = ['C',num2str(Unique_Categories(Indx_C))];
                    
                    if size(CustomERPs, 2) <Indx_P || ~isfield(CustomERPs(Indx_P), Cat)
                        CustomERPs(Indx_P).(Cat) = squeeze(nanmean(tempData(Channels, :,Trials), 1));
                    else
                        try
                        CustomERPs(Indx_P).(Cat) = cat(2, CustomERPs(Indx_P).(Cat), squeeze(nanmean(tempData(Channels, :,Trials), 1)) );
                        catch
                            a=1
                        end
                    end
                end
                
        end
        try
        AllERPs = cat(2, AllERPs, ERP);
        catch
            a=2
        end
    end
    
    if strcmp(Dimention, 'Sessions')
        plot(t, nanmean(SessionERPs, 2),'Color', Colors(Indx_S, :), 'LineWidth', 2)
    end
    
end

switch Dimention
    case 'Participants'
        ERP = nanmean(AllERPs, 1); %CHECK
        plot(t, ERP, 'Color', 'k', 'LineWidth', 3)
    case 'Custom'
        for Indx_C = 1:numel(Unique_Categories)
            
            All = [];
            Cat = ['C',num2str(Unique_Categories(Indx_C))];
            for Indx_P = 1:Participants
                
                All = cat(2, All, CustomERPs(Indx_P).(Cat));
            end
            
            plot(t, nanmean(All, 2),'Color', Colors(Indx_C, :), 'LineWidth', 2)
            Min = min(Min, min(nanmean(All, 1))');
            Max = max(Max, max(nanmean(All, 1))');
        end
end

plot([Trigger, Trigger], [min(AllERPs(:)), max(AllERPs(:))], 'Color', [.5 .5 .5])
xlabel('Time (s)')
ylim([Min, Max])
