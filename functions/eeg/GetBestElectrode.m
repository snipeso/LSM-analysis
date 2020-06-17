function Index = GetBestElectrode(EEG, Channels)
% Channels should be list of electrodes in the order in which you'd prefer
% them. This provides the index of the first that is present in the data

Channels = string(Channels);

EEG_Channels = {EEG.chanlocs.labels};

if isempty(intersect(EEG_Channels, Channels))
    warning(['No channels were found for ', EEG.filename])
    Index = [];
end


for Ch = Channels
    if ismember(Ch, EEG_Channels)
        Index = find(strcmp(EEG_Channels, Ch)); % TODO: eventually make more succint
        return
    end
end