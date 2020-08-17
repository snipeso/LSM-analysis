function Categories = SplitPhase(Phases, Point, Channel, Bins)

BandNames = fieldnames(Phases);
Sessions = fieldnames(Phases.(BandNames{1}));
Participants = numel(Phases.(BandNames{1}));

Categories = struct();
Edges = linspace(0, 2*pi, Bins+1);

for Indx_P = 1:Participants
    for Indx_B = 1:numel(BandNames)
        for Indx_S = 1:numel(Sessions)
            Ph =  Phases.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S});
            Ph = discretize(sqeeze(Ph(Channel, Point, :)), Edges);
            Categories.(BandNames{Indx_B})(Indx_P).(Sessions{Indx_S}) = Ph;
        end
    end
end