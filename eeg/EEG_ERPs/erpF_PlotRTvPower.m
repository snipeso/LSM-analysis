clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Normalize = true;

TriggerTime = 0;

Refresh = false;

Condition = 'SDvBL';
% Options: 'Beam', 'BL', 'SD'

BL_Sessions = {'BaselineBeam', 'MainPre', 'MainPost'};
SD_Sessions = {'Session2Beam1', 'Session2Beam2', 'Session2Beam3'};
PowerWindows = [-1.5 -.5;
    -.5 .1];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Load_Trials


%%%


for Indx_Ch = 1:numel(PlotChannels)
    for Indx_Pw = 1:size(PowerWindows, 1)
        
        figure
        Indx = 1;
        for Indx_B = 1:numel(BandNames)
            
            Power = [];
            RTs = [];
            SessionGroup = [];
            Participant = [];
            
            for Indx_S = 1:numel(Sessions)
                % identify group identity
                if ismember(Sessions{Indx_S}, BL_Sessions)
                    G = 1;
                elseif ismember(Sessions{Indx_S}, SD_Sessions)
                    G = 2;
                else
                    continue
                end
                for Indx_P =1:numel(Participants)
                    % get power within window
                    P = StimPower.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S});
                    if isempty(P)
                        continue
                    end
                    pStart = round((PowerWindows(Indx_Pw, 1) - Start)*HilbertFS);
                    pStop = pStart+round(diff(PowerWindows(Indx_Pw, :))*HilbertFS);
                    P = squeeze(nanmean(P(PlotChannels(Indx_Ch), pStart:pStop, :), 2));
                    
                    Power = cat(1, Power, P);
                    
                    % get RTs
                    E = allEvents(Indx_P).(Sessions{Indx_S}).rt;
                    RTs = cat(1, RTs, E);
                    
                    SessionGroup = ones(size(E))*G;
                    Participant = ones(size(E))*Indx_P;
                    
                end
            end
            
            % z-score RTs
            for Indx_P = 1:numel(Participants)
               RTs(Participant==Indx_P) = zscore(RTs(Participant==Indx_P)); 
            end
            
            % correlate
            [R, P, CI_Low, CI_Up] = corrcoef(Power, RTs, 'Rows', 'pairwise');
            
            subplot(2, ceil(numel(BandNames)/2), Indx)
            PlotConfetti(Power, RTs, SessionGroup, Format, [], Format.Colors.([Task, SDvBL]))
            xlabel([num2str(PowerWindows(Indx_Pw, 1)), ' to ',num2str(PowerWindows(Indx_Pw, 2)), 's '...
                BandNames{Indx_B}, ' power, zcored'])
            ylabel('RTs (zscored)')
            title(['R=', num2str(R, '%.2f'), ' p=', num2str(P, '%.2f')])
            Indx= Indx+1;
        end
    end
    
    
end
