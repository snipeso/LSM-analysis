

Clustering_Parameters

Folder = 'ICA';
Task = 'LAT';

Freqs = .5:.25:40;

for Indx_P = 9
    
    Path = fullfile(Paths.Preprocessing, Folder, 'SET');
    
    for Indx_S = 1:numel(Sessions)
        
        % load EEG data
        Session = Sessions{Indx_S};
        
        Filename = [strjoin({Participants{Indx_P}, Task, Session, Folder}, '_'), '.set'];
        if ~exist(fullfile(Path, Filename), 'file')
            continue
        end
        
        EEG = pop_loadset('filename', Filename, 'filepath', Path);
        
        % calculate components
        TopoComponents = EEG.icawinv;
        nComps = size(EEG.icawinv, 1); % TOCHECK!!!
        
        Weights = EEG.icaweights*EEG.icasphere;
         ICAEEG = Weights * EEG.data; % TODO: double check that this yields same results as eeglab
    
         % TODO: calculate FFT of ICAEEG
         FFT = pwelch(ICAEEG', [], [], Freqs)'; % INCORRECT
         
         % calculate Component Energy
         CE = sum(abs(ICAEEG)*(1/EEG.srate)); % double check if this is correct integral
         
         T = table('Participant', repmat(Participant, nComps, 1), ...
             'Session', repmat(Session, nComps, 1), ...
             'SDLevel', SDLevel{Indx_S}*ones(nComps, 1), ...
              'CE', CE*ones(nComps, 1));

    end
end


% gather all components from all recordings within a participant; save
% megamtrix freqs (IC x Freq) topos (IC x Topo) and table of sessions (particpant, session, SDlevel, component energy etc

% TEMP: only top 30

% run clustering on freqs

% run node averaging: average data (freqs, topos, CE, SDlevel) from every
% node, and list of all subnodes (use dictionary?)

% from Z matrix, get matrix with c1: #of subordinates c2: #of different
% recordings

% temp: visualize

% select CompNode

% look at cumulative CE for every level of SD, run a line through it. Identify nodes
% with positive correlation