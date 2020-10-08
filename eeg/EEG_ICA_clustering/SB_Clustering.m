
clear
clc
close all

Clustering_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Folder = 'ICA';
Task = 'LAT';
Refresh = false;

DistanceType = 'correlation';
LinkType = 'complete';
StructLabel = 'LATAll';
Title = StructLabel;

% % get labels
Sessions = allSessions.(StructLabel);
SessionLabels = allSessionLabels.(StructLabel);
SDLevels = [1 1 3 6 6 10 10 11 12 1]; % arbitrarily decided

% Sessions = allSessions.LATSD3;
% SessionLabels = allSessionLabels.LATSD3;
% SDLevels = [10 11 12]; % arbitrarily decided
% ColorLabel= 'LATAll';

PlotAllComps = false;

WelchWindow = 10;
MaxKeepComp = 64;
TopoThreshold = .9; %min R value accepted for topography
FFTThreshold = .9;
SplitFreq = 20;
MinBadComps = 2; % minimum number of bad components before cluster gets rejected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Paths.Figures = fullfile(Paths.Figures, Title);
if ~exist(Paths.Figures, 'dir')
    mkdir(Paths.Figures)
end

Freqs = 2.5:.1:40; % frequencies in ICA, ignoring 50hz component

SplitIndx = dsearchn( Freqs', SplitFreq);

% make place to save agregate info
Destination = fullfile(Paths.Preprocessed, 'Clustering');
if ~exist(Destination, 'dir')
    mkdir(Destination)
end


% appply seperately for each participant
for Indx_P = 11
    
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
            
            TitleTag = strjoin({Participants{Indx_P}, Task, Session, Folder, 'Components'}, '_');
            Filename = [TitleTag, '.set'];
            if ~exist(fullfile(Path, Filename), 'file')
                continue
            end
            
            EEG = pop_loadset('filename', Filename, 'filepath', Path);
            
            % get manually rejected components
            BadComps = EEG.reject.gcompreject';
            
            % get topographies of components
            Ch = cellfun(@str2num, {EEG.chanlocs.labels});
            
            TopoComponents = EEG.icawinv;
            
            % remove second half of components
            TopoComponents(:, MaxKeepComp+1:end) = [];
            
            % interpolate missing channels (maybe not good?)
            TopoComponents = interpTopo(TopoComponents, EEG.chanlocs, StandardChanlocs);
            TopoComponents = TopoComponents';
            
            
            nComps = size(TopoComponents, 1);
            AllTopo = cat(1, AllTopo, TopoComponents);
            
            % identify component energy in the time domain
            Weights = EEG.icaweights*EEG.icasphere;
            ICAEEG = Weights * EEG.data;
            
            % again, remove half of components
            ICAEEG(MaxKeepComp+1:end, :) = [];
            
            % get power spectrum for each component % POSSIBLE TODO:
            % eliminate moments in which there's not much happening
            FFT = pwelch(ICAEEG', WelchWindow*EEG.srate, [], Freqs, EEG.srate)';
            FFT = log(FFT);
            AllFFT = cat(1, AllFFT, FFT);
            
            % calculate Component Energy
            %             CE = sum(abs(ICAEEG)*(1/EEG.srate)); % double check if this is correct integral
            CE =  sum(abs(ICAEEG), 2)/(EEG.pnts); % maybe best to normalize by total time?
            
            T = table( repmat(string(Participant), nComps, 1), ...
                repmat(string(Session), nComps, 1), ...
                SDLevels(Indx_S)*ones(nComps, 1), ...
                CE, ...
                strcat(SessionLabels{Indx_S}, 'IC', string(1:nComps))', ...
                BadComps(1:MaxKeepComp),...
                'VariableNames', {'Participant','Session',  'SDLevel',  'CE',   'Label', 'BadComps'} );
            
            AllT = cat(1, AllT, T);
        end
        
        %%% make hierarchy tree by frequency
        
        % get distances by frequency between all components
        Distances = pdist(AllFFT, DistanceType);
        
        % create tree
        Links = linkage(Distances, LinkType);
        
        % save data as nodes in the tree, with info on relations
        Nodes = Unpack(Links);
        
        
        %%% get properties of each node
        
        for Indx_N = 1:numel(Nodes)
            
            Leaves = Nodes(Indx_N).Leaves;
            Nodes(Indx_N).FFT = mean(AllFFT(Leaves, :), 1); %TO DETERMINE: first log?
            Nodes(Indx_N).Topo = mean(AllTopo(Leaves, :), 1);
            Nodes(Indx_N).CE =  mean(AllT.CE(Leaves));
            Nodes(Indx_N).SD =  mean(AllT.SDLevel(Leaves));
            Nodes(Indx_N).nBadComps = nnz(AllT.BadComps(Leaves));
            
            Nodes(Indx_N).Sessions = unique(AllT.Session(Leaves));
            Nodes(Indx_N).nSessions = numel(Nodes(Indx_N).Sessions);
            
            StandardChanlocs = EEG.chanlocs;
            Nodes(Indx_N).CExSD = CE; % ????
            
        end
        save(fullfile(Destination, NodesFilename), 'Nodes', 'Links', 'StandardChanlocs', 'AllT')
    else
        load(fullfile(Destination, NodesFilename), 'Nodes', 'Links', 'StandardChanlocs', 'AllT')
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Overview plots
    Labels = AllT.Label;
    TitleTag = strjoin({Participants{Indx_P}, Task, Folder}, '_');
    if PlotAllComps
        
        % plot dendrogram with nodes
        figure('units','normalized','outerposition',[0 0 1 1])
        PlotDendro(Links, Labels);
        
        % plot topos
        PlotAllTopos(Nodes, Labels, StandardChanlocs, Format, Paths.Figures, TitleTag)
        
        % plot number of sessions represented
        PlotWalks(Nodes, Links, 'nSessions', Format)
        saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_RepresentedSessions.svg']))
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Identify clusters
    
    % get the smallest clusters that represents the most number of sessions
    Clusters = ClusterCompsBySession(Nodes, Links);
    disp(['Cluster components by session: ', num2str(numel(Clusters)), ' components'])
    
    %remove clusters with badcomps among the leaves (gets rid of eye components)
    Clusters = RemoveBadComps(Nodes, Clusters, MinBadComps);
    disp(['After removing components with artefacts: ', num2str(numel(Clusters)), ' components'])
    
    % remove clusters that are more likely noise
    Clusters = RemoveNoisyClusters(Nodes, Clusters, FFTThreshold, SplitIndx);
    
    % in case any slip through
    nSessions = [Nodes(Clusters).nSessions];
    Clusters(nSessions==1) = [];
    disp(['After removing noisy: ', num2str(numel(Clusters)), ' components'])
    
    
    % split clusters by topography
    [NewLinks, NewClusters, NewNodes, NewLabels] = SplitClustersByTopo(Clusters, Nodes, TopoThreshold, Labels, LinkType);
    disp(['After splitting components: ', num2str(numel(NewClusters)), ' components'])
    
    
    % get figure for each cluster showing topo + topo per session,
    % stacked bar of sessions represented, line x session of CE
    PlotClusters(NewNodes, NewClusters, Freqs, StandardChanlocs, Format, Sessions, ...
        SessionLabels, NewLabels, StructLabel, [Paths.Figures, '\', [TitleTag, 'FinalClusters']]);
    
    PlotClusterDendro(NewClusters, NewLinks, NewNodes, Format, NewLabels);
    saveas(gcf,fullfile(Paths.Figures, [TitleTag, '_FinalClusterTree.svg']))
end


