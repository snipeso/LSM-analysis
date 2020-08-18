function PlotPhaseRTs(Phases, Channel, PhasePoints, Events, Tally, Title, Format)
%phase points is a 2xn matrix, with row 1 indices, and row 2 times

nBins = 10;
BandNames = fieldnames(Phases);
nPoints = size(PhasePoints, 2);
% plot RTs split by phase, across phase points
figure('units','normalized','outerposition',[0 0 1 1])
Indx = 1;
for Indx_B = 1:numel(BandNames)
    for Indx_P = 1:nPoints
        
        AllPhases = ConcatStruct(Phases.(BandNames{Indx_B}), Channel, PhasePoints(1,Indx_P));
        AllRTs = ConcatTable(Events, 'rt');
         AX = subplot(numel(BandNames)*2, nPoints, Indx, polaraxes);
        PlotPolar(AllPhases, AllRTs, nBins, Format, AX)
        title([num2str(round(PhasePoints(2, Indx_P)*1000)), ' ', BandNames{Indx_B}, Title, ' RT'])
        Indx=Indx+1;
    end
    
end

% plot tally split by phase across phase points
for Indx_B = 1:numel(BandNames)
    for Indx_P = 1:nPoints
        
        AllPhases = ConcatStruct(Phases.(BandNames{Indx_B}), Channel, PhasePoints(1, Indx_P));
        AllTally = ConcatStruct(Tally, [],[]);
         AX = subplot(numel(BandNames)*2, nPoints, Indx, polaraxes);
        PlotPolarTally(AllPhases, AllTally, nBins, Format.Legend.Tally, Format, AX)
         title([num2str(round(PhasePoints(2, Indx_P)*1000)), ' ', BandNames{Indx_B}, Title, ' Tally'])
        Indx=Indx+1;
    end
    
end
end



function All = ConcatStruct(Structure, Channel, TimePoint)
All = [];
for Indx_P = 1:numel(Structure)
    Sessions = fieldnames(Structure);
    for Indx_S = 1:numel(Sessions)
        if isempty(Channel) && isempty(TimePoint)
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