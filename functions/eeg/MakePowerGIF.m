function MakePowerGIF(Path, Filename, Hilbert, t, BandNames, Chanlocs,...
    StartTime, EndTime, oldfs, newfs, Slowdown, Colormap, FontName)

Filepath = fullfile(Path, [Filename, num2str(StartTime), '-', num2str(EndTime), '.gif']);

close all
% Make destination if it doesn't exist
if ~exist(Path, 'dir')
    mkdir(Path)
end

[~, StartPoint] = min(abs(t-StartTime));
[~, EndPoint] = min(abs(t-EndTime));

% Hilbert_Short = log(Hilbert(:, round(StartTime*oldfs):round(EndTime*oldfs), :));
Hilbert_Short = Hilbert(:, StartPoint:EndPoint, :);

t_short = t(StartPoint:EndPoint);

Points = size(Hilbert_Short, 2);
Gap = (1/newfs)*Slowdown;

figure('units','normalized','outerposition',[0 0 .6 .3])
set(gcf,'color','w')

Frames = (Points/oldfs)*newfs;
Edges = floor(linspace(1, Points, Frames +1));

if ~exist('Colormap', 'var')
    colormap('plasma')
else
    colormap(Colormap)
end

% color limits
CLims = zeros(numel(BandNames), 2);
for Indx_B = 1:numel(BandNames)
    
    All = Hilbert( :, :, Indx_B);
    CLims(Indx_B, :) = [quantile(All(:), .005), quantile(All(:), .995)];
end
CLims = [min(CLims(:, 1)), max(CLims(:, 2))];

for Indx_F = 1:Frames
    figure(1)
    
    MeanFrame = nanmean(Hilbert_Short(:, Edges(Indx_F):Edges(Indx_F+1), :), 2);
    for Indx_B = 1:numel(BandNames)
        
        subplot(1, numel(BandNames), Indx_B)
        topoplot(squeeze(MeanFrame(:, :, Indx_B)), Chanlocs, 'maplimits', CLims, ...
            'style', 'map', 'headrad', 'rim', 'colormap', colormap(Colormap), ...
            'gridscale', 150)
        title([BandNames{Indx_B}, ' (', num2str(round(1000*t_short(Edges(Indx_F)))), ')' ], 'FontSize', 14, 'FontName', FontName)
    end
    set(gcf,'color','w')
    drawnow
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if Indx_F == 1
        imwrite(imind,cm,Filepath,'gif','Loopcount',inf,'DelayTime',Gap);
    else
        imwrite(imind,cm,Filepath,'gif','WriteMode','append','DelayTime',Gap);
    end
    
    
end


close all
