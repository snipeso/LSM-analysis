function PlotERP(t, Data, Trigger, Channels, Dimention, Colors, Category)


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
        SessionERPs = nan(Participants, Points);
    end
    
    for Indx_P = 1:Participants
        
        tempData = Data(Indx_P).(Sessions{Indx_S});
        if isempty(tempData)
            continue
        end
        switch Dimention
            case 'Participants'
                ERP = nanmean(nanmean(tempData(Channels, :, :), 1), 3);
                plot(t, ERP, 'Color', Colors(Indx_P, :), 'LineWidth', 2)
            case 'Sessions'
                ERP = nanmean(nanmean(tempData(Channels, :, :), 1), 3);
                SessionERPs(Indx_P, :) = ERP;
                Min = min(Min, min(ERP(:)));
                Max = max(Max, max(ERP(:)));
            case 'Custom'
                
                for Indx_C = 1:numel(Unique_Categories)
                    Trials =  Category(Indx_P).(Sessions{Indx_S})== Unique_Categories(Indx_C);
                    ERP = nanmean(nanmean(tempData(Channels, :,Trials), 1), 3);
                    %                     CustomERPs(Indx_P, :, Indx_C) = ERP; %TODO: try cat all stimuli, so ERP is smoother
                    Cat = ['C',num2str(Unique_Categories(Indx_C))];
                    
                    if size(CustomERPs, 2) <Indx_P || ~isfield(CustomERPs(Indx_P), Cat)
                        CustomERPs(Indx_P).(Cat) = nanmean(tempData(Channels, :,Trials), 1);
                    else
                        CustomERPs(Indx_P).(Cat) = cat(3, CustomERPs(Indx_P).(Cat),nanmean(tempData(Channels, :,Trials), 1) );
                    end
                end
                
        end
        AllERPs = cat(1, AllERPs, ERP);
    end
    
    if strcmp(Dimention, 'Sessions')
        plot(t, nanmean(SessionERPs, 1),'Color', Colors(Indx_S, :), 'LineWidth', 2)
    end
    
end

switch Dimention
    case 'Participants'
        ERP = nanmean(AllERPs, 1); %CHECK
        plot(t, ERP, 'Color', 'k', 'LineWidth', 3)
    case 'Custom'
        for Indx_C = 1:numel(Unique_Categories)
            
            All = nan(Participants, Points);
            Cat = ['C',num2str(Unique_Categories(Indx_C))];
            for Indx_P = 1:Participants
                
                All(Indx_P, :) = nanmean(CustomERPs(Indx_P).(Cat), 3);
                
                %                 plot(t, All(Indx_P, :), 'Color',[.8 .8 .8], 'LineWidth', .1) % TEMP
            end
            
            plot(t, nanmean(All, 1),'Color', Colors(Indx_C, :), 'LineWidth', 2)
            Min = min(Min, min(nanmean(All, 1))');
            Max = max(Max, max(nanmean(All, 1))');
        end
end

plot([Trigger, Trigger], [min(AllERPs(:)), max(AllERPs(:))], 'Color', [.5 .5 .5])
xlabel('Time (s)')
ylim([Min, Max])
