function MakeGIF(Path, Filename, Data, Chanlocs, Ch, nFrames, Gap, Colormap)

% location and new filename
Filepath = fullfile(Path, [Filename, '.gif']);

% Make destination if it doesn't exist
if ~exist(Path, 'dir')
    mkdir(Path)
end

Pnts = size(Data, 2);
% CLims = quantile(Data(:), [.01, .99]);
Max = max(abs(Data(Ch, :)));
CLims = [-Max, Max];
Frames = 1:nFrames:Pnts;

figure('units','normalized','outerposition',[0 0 .25 .25])
set(gcf,'color','w') % set background to white?

fig = get(groot,'CurrentFigure');

if ~exist('Colormap', 'var')
    colormap('gray')
else
    colormap(Colormap)
end

if ~exist('FontName', 'var')
    FontName = 'Ariel';
end

 

for F = Frames
    subplot(1, 2, 1)
      topoplot(Data(:, F), Chanlocs, 'maplimits', CLims, ...
            'style', 'map', 'headrad', 'rim', 'colormap', colormap(Colormap), ...
            'gridscale', 100);
        
        
        subplot(1, 2, 2)     

plot(Data(Ch, :), 'Color', Colormap(3, :))
hold on
scatter(F, Data(Ch, F), 'filled')
 set(gca,'visible','off')
set(gca,'xtick',[])
hold off
 
        
     set(gcf,'color','w')
    drawnow
    frame = getframe(fig.Number);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if F == 1
        imwrite(imind,cm,Filepath,'gif','Loopcount',inf,'DelayTime',Gap);
    else
        imwrite(imind,cm,Filepath,'gif','WriteMode','append','DelayTime',Gap);
    end
    clf
end
close all