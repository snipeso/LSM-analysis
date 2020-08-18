function PlotPhaseRTs(Phases, Channel, PhasePoints, Events, Tally, Title, Format)

nBins = 40;
BandNames = fieldnames(Phases);

% plot RTs split by phase, across phase points
figure('units','normalized','outerposition',[0 0 1 1])
Indx = 1;
for Indx_B = 1:numel(BandNames)
    for Indx_P = 1:numel(PhasePoints)
        
        AllPhases = ConcatStruct(Phases.(BandNames{Indx_B}), Channel, PhasePoints(Indx_P));
        AllRTs = ConcatTable(Events, 'rt');
        subplot(numel(BandNames)*2, numel(PhasePoints), Indx)
        PlotPolar(AllPhases, AllRTs, nBins, Format)
        title([num2str(round(PhasePoints*1000)), ' ', BandNames{Indx_B}, Title, ' RT'])
        Indx=Indx+1;
    end
    
end

% plot tally split by phase across phase points
for Indx_B = 1:numel(BandNames)
    for Indx_P = 1:numel(PhasePoints)
        
        AllPhases = ConcatStruct(Phases.(BandNames{Indx_B}), Channel, PhasePoints(Indx_P));
        AllTally = ConcatStruct(Tally, [],[]);
        subplot(numel(BandNames)*2, numel(PhasePoints), Indx)
        PlotPolarTally(AllPhases, AllTally, nBins, Format.Legend.Tally, Format)
         title([num2str(round(PhasePoints*1000)), ' ', BandNames{Indx_B}, Title, ' Tally'])
        Indx=Indx+1;
    end
    
end
end



function All = ConcatStruct(Structure, Channel, TimePoint)
All = [];
for Indx_P = 1:numel(Structure)
    Sessions = fieldnames(Structure);
    for Indx_S = 1:numel(Sessions)
        if isemtpy(Channel) && isempty(TimePoint)
            Points = Structure(Indx_P).(Sessions{Indx_S});
        else
               Points = Structure(Indx_P).(Sessions{Indx_S})(Channel, TimePoint, :);
        end
             All = cat(1, All, Points(:));
    end
end
end


function All = ConcatTable(Structure, Field)
All = [];
for Indx_P = 1:numel(Structure)
    Sessions = fieldnames(Structure);
    for Indx_S = 1:numel(Sessions)
        Points = Structure(Indx_P).(Sessions{Indx_S}).(Field);
        All = cat(1, All, Points(:));
    end
end
end