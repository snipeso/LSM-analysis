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
                if isempty(tempData)
                    ERP = [];
                elseif ndims(tempData)<3
                    
                    ERP = nanmean(tempData(Channels, :));
                    ERP = ERP';
                else
                    ERP = squeeze(nanmean(tempData(Channels, :, :), 1)); % average across channels
                end
                ERPs = cat(2, ERPs, ERP);
            end
            
            pERP = PlotSingle(ERPs, t, Colors(Indx_P, :));
            AllERPs(Indx_P, :) = pERP;
        end
        
        plot(t, nanmean(AllERPs), 'k', 'LineWidth', 3)
        Stats(AllERPs, t)
        
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

% plot line of trigger % TODO: make it possible to provide list?
Min = min(AllERPs(:));
Max = max(AllERPs(:));

ylim([Min, Max])

plot([Trigger, Trigger], [Min, Max], 'Color', [.7 .7 .7])

end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions

function ERP = PlotSingle(ERPs, t, Color)

if isempty(ERPs)
    ERP = nan(size(t));
    return
end

fs = 1/(diff(t(1:2)));


ERP = nanmean(ERPs, 2);
ERP = smooth(ERP, fs/10);

plot(t, ERP', 'Color', Color, 'LineWidth', 1)


end

function Stats(Matrix, t)
% Matrix is participants x time x group

PeriodLength = 20; % ms
End = size(Matrix, 2);
fs = 1/(diff(t(1:2)));
Period = (PeriodLength/1000)*fs;

Starts = round(1:Period+1:End+1);
Stops = round(Starts-1);
Stops(1) = []; % remove starting 0

pValues = ones(numel(Stops), 1);
for Indx_S = 1:numel(Stops)
    
    if ndims(Matrix) < 3 %run a t-test
        Data = squeeze(nanmean(Matrix(:, Starts(Indx_S):Stops(Indx_S)), 2));

        [~, p] = ttest(Data);
    else
        Data = squeeze(nanmean(Matrix(:, Starts(Indx_S):Stops(Indx_S), :), 2));
        [stats, ~] = mes1way(Data, 'eta2', 'isDep',1); %  'nBoot', 1000
        p = 1;
    end
    
    
    pValues(Indx_S) = p;
end

GrandMean = nanmean(Matrix, 1);
Max = max(GrandMean(:));
Min = min(GrandMean(:));
Ceiling = Max+(Max-Min)*0.1;

[~, pValuesFDR] = fdr(pValues, .05);
pValuesFDR = pValues(pValuesFDR);

Sig_pValues = nan(size(pValues));
Sig_pValues(pValues<=.05) = Ceiling;
Sig_pValues(pValues>.05) = nan;


Sig_pValuesFDR = nan(size(pValuesFDR));
Sig_pValuesFDR(pValuesFDR<=.05) = Ceiling;
Sig_pValuesFDR(pValuesFDR>.05) = nan;

hold on
plot(linspace(t(1), t(end), numel(Sig_pValues)), Sig_pValues, 'LineWidth', 4, 'Color', [.5 0.5 0.5])
plot(linspace(t(1), t(end), numel(Sig_pValuesFDR)), Sig_pValuesFDR, 'LineWidth', 4, 'Color', [0 0 0])


  if ndims(Matrix) < 3 
      plot(t, zeros(size(Matrix, 2), 1), 'Color', [.7 .7 .7])

  end
% TODO: split by larger significance?
end
