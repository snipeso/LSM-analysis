function PlotClusters(Nodes, Clusters, Freqs, Chanlocs, Format, ...
    Sessions, SessionLabels, Labels, ColorLabel, Destination)

subX = 3;
subY = 5;

for Indx_C = 1:numel(Clusters)
    C = Clusters(Indx_C);
    figure('units','normalized','outerposition',[0 0 1 1])
    subplot(subX, subY, 1)
    topoplot(Nodes(C).Topo, Chanlocs, ...
        'style', 'map', 'headrad', 'rim', 'gridscale', 150);
    title(['N', num2str(C)])
    colormap(Format.Colormap.Divergent)
    
    
    
    
    % plot session topos
    Leaves = Nodes(C).Leaves;
    lSessions = [Nodes(Leaves).Sessions];
    if numel(lSessions) ~= numel(Leaves)
        error('problem')
    end
    
    nSession = zeros(numel(Sessions));
    CExSession = nan(numel(Sessions));
    for Indx_S = 1:numel(Sessions)
        L = Leaves(strcmp(lSessions, Sessions{Indx_S})); % get all leaves of current session
        Topos = cat(1, Nodes(L).Topo);  %warning! this is IC x ch
        
        subplot(subX, subY, subY+Indx_S) % second row
        
        topoplot(mean(Topos, 1), Chanlocs, ...
            'style', 'map', 'headrad', 'rim', 'gridscale', 200);
        title([SessionLabels{Indx_S}, ' (', num2str(nnz(L)), ')'])
        
        nSession(Indx_S) = nnz(L);
        
        CExSession(Indx_S) = nansum([Nodes(L).CE]);
    end
    colormap(Format.Colormap.Divergent)
    
    % plot proportion of sessions
    subplot(subX,  subY, 2)
    Colors = Format.Colors.(ColorLabel);
    PlotStacks(nSession', Colors)
    xlim([0, 2])
    legend(SessionLabels)
    
    % plot component energy by session
    subplot(subX,  subY, 3)
    plot(CExSession, 'o-')
    xticks(1:numel(Sessions))
    xlim([0, numel(Sessions)+1])
    xticklabels(SessionLabels)
    title(['CE (SD: ', num2str(Nodes(C).SD), ')'])
    
    
    % plot butterfly of spectrums
    subplot(subX,  subY, 4)
    hold on
    for Indx_L = 1:numel(Leaves)
        plot(Freqs, Nodes(Leaves(Indx_L)).FFT, 'LineWidth', 1, ...
            'Color', [Colors(strcmp(Sessions,  Nodes(Leaves(Indx_L)).Sessions) ,:), .3])
    end
    xlabel('Frequency (Hz)')
    
    AllFFT = cat(1,  Nodes(Leaves).FFT);
    R =  corrcoef(AllFFT');
    title(['FFT R: ', num2str(mean(R(:)))])
    
    
    % plot little tree of connections between these components
    D = pdist(cat(1,  Nodes(Leaves).FFT), 'correlation');
    L = linkage(D, 'average');
    Lbls = Labels(Leaves);
    
    subplot(subX,  subY, 5)
    PlotDendro(L, Lbls)
    title(['Mean D: ', num2str(mean(L(:, 3))) ])
    set(gca, 'FontSize', 5)
    saveas(gcf, [Destination, num2str(C), '_ClusterInfo.svg'])
end

