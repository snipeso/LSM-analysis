function PlotERP(t, Data, Trigger, Channels, Dimention, Colors, Category)
% t is vector of timepoints to plot
% Data is Struct(Participant).(Session)(ch x time x trial)
% Channels is list of indices to plot
% Dimention is what gets seperately averaged. Options: 'Participants',
% 'Session', 'Custom', and ''. The last just plots one big ERP


Sessions = fieldnames(Data);
Participants = size(Data, 2);
Points = size(Data(1).(Sessions{1}), 2);

hold on
switch Dimention
    case 'Participants'
        
        AllERPs = nan(Participants, Points);
        
        % plots all trials of participant
        for Indx_P = 1:Participants
            ERPs = [];
            for Indx_S = 1:numel(Sessions)
                tempData = Data(Indx_P).(Sessions{Indx_S});
                ERP = squeeze(nanmean(tempData(Channels, :, :), 1)); % average across channels
                ERPs = cat(2, ERPs, ERP);
            end
            
            pERP = nanmean(ERPs, 2);
            pERP = smooth(pERP);
            AllERPs(Indx_P, :) = pERP;
            plot(t, pERP, 'Color', Colors(Indx_P, :), 'LineWidth', 1)
        end
        
        plot(t, nanmean(AllERPs), 'k', 'LineWidth', 1)
        Stats(AllERPs)
        
    case 'Session'
        
        % plots all participants' sessions averaged
        for Indx_S = 1:numel(Sessions)
            ERPs = [];
            for Indx_P = 1:Participants
                tempData = Data(Indx_P).(Sessions{Indx_S});
                ERP = squeeze(nanmean(tempData(Channels, :, :), 1)); % average across channels
                ERPs = cat(2, ERPs, ERP);
            end
            
            sERP = nanmean(ERPs, 2);
            AllERPs = cat(2, AllERPs, sERP);
            plot(t, sERP, 'Color', Colors(Indx_S, :), 'LineWidth', 1)
        end
        
    case 'Custom'
        
        % group by inputted categories
        Unique_Categories = unique(Category(1).(Sessions{1}));
        
        % emergency color thing so I don't have to care all the time
        if numel(Unique_Categories)>size(Colors, 1)
            Colors = gray(numel(Unique_Categories));
        end
        
        for Indx_C = 1:numel(Unique_Categories)
            ERPs = [];
            for Indx_P = 1:Participants
                for Indx_S = 1:numel(Sessions)
                    tempData = Data(Indx_P).(Sessions{Indx_S});
                    Trials =  Category(Indx_P).(Sessions{Indx_S}) == Unique_Categories(Indx_C);
                    
                    ERP = squeeze(nanmean(tempData(Channels, :,Trials), 1));
                    ERPs = cat(2, ERPs, ERP);
                end
            end
            
            cERP = nanmean(ERPs, 2);
            AllERPs = cat(2, AllERPs, cERP);
            plot(t, cERP, 'Color', Colors(Indx_C, :), 'LineWidth', 1)
        end
    otherwise
        % plot thin gray lines for each recording average
end

end

function Stats(Matrix, srate)
% Matrix is participants x time x group




 [stats, Table] = mes1way(Matrix, 'eta2', 'isDep',1,'nBoot', 1000);

 sigstar()
 
end
