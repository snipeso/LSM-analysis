
clear
clc
close all

Clustering_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Folder = 'ICA';
Task = 'LAT';
Refresh = true;

DistanceType = 'correlation';
LinkType = 'complete';
Title = 'ALL';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Freqs = 2.5:.1:40; % frequencies in ICA, ignoring 50hz component

% make place to save agregate info
Destination = fullfile(Paths.Preprocessed, 'Clustering');
if ~exist(Destination, 'dir')
    mkdir(Destination)
end

% get labels
Sessions = allSessions.LATAll;
SessionLabels = allSessionLabels.LATAll;
SDLevels = [1 1 3 6 6 10 10 11 12 1]; % arbitrarily decided

% Sessions = allSessions.LATSD3;
% SessionLabels = allSessionLabels.LATSD3;
% SDLevels = [10 11 12]; % arbitrarily decided


% appply seperately for each participant
for Indx_P = 9
    
    Participant = Participants{Indx_P};
    Path = fullfile(Paths.Preprocessed, Folder, 'Components', Task);
    NodesFilename = [strjoin([Participants(Indx_P), Task, Folder, Title], '_'), '.mat'];
    
    
    %%% get hierarchy of independent components, and relevant information
    %%% across all sessions within a participant
    if Refresh || ~exist(fullfile(Destination, NodesFilename), 'file')
        
        load('StandardChanlocs128.mat', 'StandardChanlocs')
        
        AllTopo = [];
        AllFFT = [];
        AllT = [];
        
        for Indx_S = 1:numel(Sessions)
            
            % load EEG data
            Session = Sessions{Indx_S};
            
            Filename = [strjoin({Participants{Indx_P}, Task, Session, Folder, 'Components'}, '_'), '.set'];
            if ~exist(fullfile(Path, Filename), 'file')
                continue
            end
            
            EEG = pop_loadset('filename', Filename, 'filepath', Path);
            
            
            % get topographies of components
           Ch = cellfun(@str2num, {EEG.chanlocs.labels}); 
            
            TopoComponents = EEG.icawinv;
            TopoComponents(:, 31:end) = []; % TEMP
            
            % interpolate missing channels (maybe not good?)
             TopoComponents = interpTopo(TopoComponents, EEG.chanlocs, StandardChanlocs);
             TopoComponents = TopoComponents';
             
            
            nComps = size(TopoComponents, 1);
            AllTopo = cat(1, AllTopo, TopoComponents);
            
            % identify component energy in the time domain
            Weights = EEG.icaweights*EEG.icasphere;
            ICAEEG = Weights * EEG.data; % TODO: double check that this yields same results as eeglab
            ICAEEG(31:end, :) = []; % TEMP
            
            % get power spectrum for each component % POSSIBLE TODO:
            % eliminate moments in which there's not much happening
            FFT = pwelch(ICAEEG', [], [], Freqs, EEG.srate)';
            AllFFT = cat(1, AllFFT, FFT);
            
            % calculate Component Energy
            %             CE = sum(abs(ICAEEG)*(1/EEG.srate)); % double check if this is correct integral
            CE =  sum(abs(ICAEEG), 2)/(EEG.pnts/EEG.srate); % maybe best to normalize by total time?
            
            T = table( repmat(string(Participant), nComps, 1), ...
                repmat(string(Session), nComps, 1), ...
                SDLevels(Indx_S)*ones(nComps, 1), ...
                CE, ...
                strcat(SessionLabels{Indx_S}, 'IC', string(1:nComps))', ...
                'VariableNames', {'Participant','Session',  'SDLevel',  'CE',   'Label', } );
            
            AllT = cat(1, AllT, T);
            
        end
        
        % cluster all components by frequency
        Distances = pdist(AllFFT, DistanceType);
        
        Links = linkage(Distances, LinkType);
        
        % get all leaf components for each node in hierarchy
        Nodes = Unpack(Links);
        
        % get properties of each node
        for Indx_N = 1:numel(Nodes)
            
            Leaves = Nodes(Indx_N).Leaves;
            Nodes(Indx_N).FFT = mean(AllFFT(Leaves, :), 1); %TO DETERMINE: first log?
            Nodes(Indx_N).Topo = mean(AllTopo(Leaves, :), 1);
            Nodes(Indx_N).CE =  mean(AllT.CE(Leaves));
            Nodes(Indx_N).SD =  mean(AllT.SDLevel(Leaves));
            
            Nodes(Indx_N).Sessions = unique(AllT.Session(Leaves));
            Nodes(Indx_N).nSessions = numel(Nodes(Indx_N).Sessions);
            
            % get CE for each level of SD
            CE = zeros(2, numel(SDLevels));
            CE(1, :) = SDLevels;
            for Indx_SD = 1:numel(SDLevels)
                nCE = AllT(Leaves, :); % node's components' energies
                CE(2, Indx_SD) = mean(nCE.CE(strcmp(nCE.Session, Sessions{Indx_SD})));
            end
            
            Chanlocs = EEG.chanlocs;
            save(fullfile(Destination, NodesFilename), 'Nodes', 'Links', 'Chanlocs', 'AllT', '-v7.3')
            
        end
        
    else
        load(fullfile(Destination, NodesFilename), 'Nodes', 'Links', 'Chanlocs', 'AllT')
        
    end
    
    % plot dendrogram with nodes
    Labels = AllT.Label;
    PlotDendro(Links, Labels)
    
    
    % plot topos
    figure('units','normalized','outerposition',[0 0 1 1])
    Indx = 0;
    for Indx_N = 1:numel(Nodes)
        if Indx >= 32
            colormap(Format.Colormap.Divergent)
            figure('units','normalized','outerposition',[0 0 1 1])
            Indx = 0;
        end
        
        Indx = Indx+1;
        subplot(4, 8, Indx)
        topoplot(Nodes(Indx_N).Topo, Chanlocs, ...
              'style', 'map', 'headrad', 'rim', 'gridscale', 150); % TODO look at other scripts to make nice
        
          if Indx_N <=numel(Labels)
              title(['N', num2str(Indx_N), ' (', Labels{Nodes(Indx_N).Leaves}, ')'])
          else
          title(['N', num2str(Indx_N)])
          end
    end
     colormap(Format.Colormap.Divergent)
   
    
end

% from Z matrix, get matrix with c1: #of subordinates c2: #of different
% recordings

% temp: visualize

% select CompNode

% look at cumulative CE for every level of SD, run a line through it. Identify nodes
% with positive correlation