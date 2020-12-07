function PlotERP(t, Data, Trigger, Channels, BLPoints, Dimention, Colors, Category)
% t is vector of timepoints to plot
% Data is Struct(Participant).(Session)(ch x time x trial)
% Channels is list of indices to plot
% Dimention is what gets seperately averaged. Options: 'Participants',
% 'Session', 'Custom', and ''. The last just plots one big ERP

PeriodLength = 20;

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
                
                
                if isempty(tempData) % skip if empty
                    ERP = [];
                elseif ndims(tempData)<3 % deal with 1 trial session
                    
                    % baseline correction TOCHECK
                    if ~isempty(BLPoints)
                        BL = tempData(:, BLPoints(1):BLPoints(2));
                        if nnz(isnan(BL(1, :))) > numel(BL(1, :))/3 % skip if there's not enough baseline
                            continue
                        end
                        tempData = tempData - nanmean(BL, 2);
                    end
                    
                    ERP = nanmean(tempData(Channels, :));
                    ERP = ERP';
                else
                    if ~isempty(BLPoints)
                        BL = tempData(:, BLPoints(1):BLPoints(2), :);
                        %                         if nnz(isnan(BL(1, :))) > numel(BL(1, :))/3 % skip if there's not enough baseline
                        %                             continue
                        %                         end
                        tempData = tempData - nanmean(BL, 2);
                    end
                    
                    ERP = squeeze(nanmean(tempData(Channels, :, :), 1)); % average across channels
                end
                
                ERPs = cat(2, ERPs, ERP);
            end
            
            pERP = PlotSingle(ERPs, t, Colors(Indx_P, :), true);
            AllERPs(Indx_P, :) = pERP;
        end
        
        plot(t, nanmean(AllERPs), 'k', 'LineWidth', 3)
        TimeSeriesStats(AllERPs, t, PeriodLength)
        
    case 'Sessions'
        
        AllERPs =  nan(Participants, Points, numel(Sessions));
        
        % plots all participants' sessions averaged
        for Indx_S = 1:numel(Sessions)
            
            for Indx_P = 1:Participants
                tempData = Data(Indx_P).(Sessions{Indx_S});
                
                if isempty(tempData) % skip if empty
                    ERP = [];
                elseif ndims(tempData)<3 %#ok<*ISMAT> % deal with 1 trial session
                    
                    
                    % baseline correction TOCHECK
                    if ~isempty(BLPoints)
                        BL = tempData(:, BLPoints(1):BLPoints(2));
                        if nnz(isnan(BL(1, :))) > numel(BL(1, :))/3 % skip if there's not enough baseline
                            continue
                        end
                        tempData = tempData - nanmean(BL, 2);
                    end
                    
                    ERP = nanmean(tempData(Channels, :));
                    ERP = ERP';
                else
                    if ~isempty(BLPoints)
                        BL = tempData(:, BLPoints(1):BLPoints(2), :);
                        %                         if nnz(isnan(BL(1, :))) > numel(BL(1, :))/3 % skip if there's not enough baseline
                        %                             continue
                        %                         end
                        tempData = tempData - nanmean(BL, 2);
                    end
                    
                    ERP = squeeze(nanmean(tempData(Channels, :, :), 1)); % average across channels
                end
                
                sERP = PlotSingle(ERP, t, [], false);
                AllERPs(Indx_P, :, Indx_S) = sERP;
                
                
            end
            
            PlotSingle(squeeze(AllERPs(:, :, Indx_S))', t, Colors(Indx_S, :), true);
        end
        
        TimeSeriesStats(AllERPs, t, PeriodLength)
        
    case 'Custom'
        
        % group by inputted categories
        Unique_Categories = unique(Category(1).(Sessions{1}));
        
        AllERPs =  nan(Participants, Points, numel(Unique_Categories));
        
        % emergency color thing so I don't have to care all the time
        if numel(Unique_Categories)>size(Colors, 1)
            Colors = gray(numel(Unique_Categories));
        end
        
        for Indx_C = 1:numel(Unique_Categories)
            
            for Indx_P = 1:Participants
                ERPs = [];
                for Indx_S = 1:numel(Sessions)
                    tempData = Data(Indx_P).(Sessions{Indx_S});
                    Trials =  Category(Indx_P).(Sessions{Indx_S}) == Unique_Categories(Indx_C);
                    
                    if isempty(tempData) % skip if empty
                        ERP = [];
                    elseif ndims(tempData)<3 %#ok<*ISMAT> % deal with 1 trial session
                        
                        if ~isempty(BLPoints)
                            % baseline correction TOCHECK
                            BL = tempData(:, BLPoints(1):BLPoints(2));
                            if nnz(isnan(BL(1, :))) > numel(BL(1, :))/3 % skip if there's not enough baseline
                                continue
                            end
                            tempData = tempData - nanmean(BL, 2);
                        end
                        
                        ERP = nanmean(tempData(Channels, :), 1);
                        ERP = ERP';
                    else
                        if ~isempty(BLPoints)
                            BL = tempData(:, BLPoints(1):BLPoints(2), :);
                            %                         if nnz(isnan(BL(1, :))) > numel(BL(1, :))/3 % skip if there's not enough baseline
                            %                             continue
                            %                         end
                            tempData = tempData - nanmean(BL, 2);
                        end
                        
                        ERP = squeeze(nanmean(tempData(Channels, :, Trials), 1)); % average across channels
                        if nnz(Trials) == 1 %TODO, merge with first attempt at fixing this
                            ERP = ERP';
                        end
                    end
                    
                    try
                        ERPs = cat(2, ERPs, ERP);
                    catch
                        a = 1
                    end
                    
                end
                
                cERP = PlotSingle(ERPs, t, [], false);
                disp([num2str(Indx_P), ' has ', num2str(size(ERPs, 2)), ' type ', num2str(Indx_C) ' trials'])
                AllERPs(Indx_P, :, Indx_C) = cERP;
            end
            
            PlotSingle(squeeze(AllERPs(:, :, Indx_C))', t, Colors(Indx_C, :), true);
            A =1;
        end
        
        TimeSeriesStats(AllERPs, t, PeriodLength)
        
        
    otherwise
        % plot thin gray lines for each recording average
end

% plot line of trigger % TODO: make it possible to provide list?
Min = min(AllERPs(:));
Max = max(AllERPs(:));


plot([Trigger, Trigger], [Min, Max], 'Color', [.7 .7 .7])

end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions

function ERP = PlotSingle(ERPs, t, Color, Plot)

if isempty(ERPs)
    ERP = nan(size(t));
    return
elseif size(ERPs, 2) < 10
    ERP = nan(size(t));
    warning('not enough trials')
    return
end

fs = 1/(diff(t(1:2)));


ERP = nanmean(ERPs, 2);
% ERP = smooth(ERP, fs/20);

if Plot
    plot(t, ERP', 'Color', Color, 'LineWidth', 2)
end

end
