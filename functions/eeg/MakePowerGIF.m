function MakePowerGIF(Path, Filename, Data, t, Labels, Chanlocs,...
    StartTime, EndTime, oldfs, newfs, Slowdown, Colormap, FontName)
% function creates a gif of topoplots changing over time. This relies on
% EEGLAB functions.

% Path: location where you want the GIF saved
% Filename: main part of the filename. It will automatically add the time
% window chosen and the extention
% Data: a channel x time (optional: x frequency band) matrix with the data
% to plot. Recommend using either ERP or power values
% t: vector with timepoints.
% Labels: if plotting multiple frequency bands, this is a cell array of
% labels (e.g. {'delta', 'theta', 'alpha'}. If the matrix is just 2
% dimentions, then this is just 1 item e.g. {'ERP'}
% Chanlocs: structure of channel info (EEGLAB)
% StartTime, EndTime: time in whatever unit you fed t. This will limit how
% much of the data gets plotted
% oldfs: the sampling frequency of the Data
% newfs: how often you want a frame to represent the data
% Slowdown: how much you want to slow down the gif; this should be decided
% via trial and error based on the newfs and the data.
% Colormap: colormap with which to plot. can leave this and next variable
% blank.
% FontName: self explanatory.


% location and new filename
Filepath = fullfile(Path, [Filename, num2str(StartTime), '-', num2str(EndTime), '.gif']);


% Make destination if it doesn't exist
if ~exist(Path, 'dir')
    mkdir(Path)
end

% find subsection of data to plot
[~, StartPoint] = min(abs(t-StartTime));
[~, EndPoint] = min(abs(t-EndTime));

Hilbert_Short = Data(:, StartPoint:EndPoint, :);
t_short = t(StartPoint:EndPoint);

Points = size(Hilbert_Short, 2);
Gap = (1/newfs)*Slowdown; % how much time passes between frames

Frames = (Points/oldfs)*newfs;
Edges = floor(linspace(1, Points, Frames +1));

%%% start figure
close all
figure('units','normalized','outerposition',[0 0 .6 .3])

% set colors and fonts
set(gcf,'color','w') % set background to white?

if ~exist('Colormap', 'var')
    colormap('gray')
else
    colormap(Colormap)
end

if ~exist('FontName', 'var')
    FontName = 'Ariel';
end

% get color limits
CLims = zeros(numel(Labels), 2);
for Indx_L = 1:numel(Labels)
    All = Data( :, :, Indx_L);
    CLims(Indx_L, :) = quantile(All(:), [.005, .995]);
end
CLims = [min(CLims(:, 1)), max(CLims(:, 2))];

% loop through and plot each frame that goes into gif
for Indx_F = 1:Frames
    figure(1)
    
    % average data for the frame
    MeanFrame = nanmean(Hilbert_Short(:, Edges(Indx_F):Edges(Indx_F+1), :), 2);
    
    % loop through topoplots
    for Indx_L = 1:numel(Labels)
        
        subplot(1, numel(Labels), Indx_L)
        topoplot(squeeze(MeanFrame(:, :, Indx_L)), Chanlocs, 'maplimits', CLims, ...
            'style', 'map', 'headrad', 'rim', 'colormap', colormap(Colormap), ...
            'gridscale', 150)
        title([Labels{Indx_L}, ' (', num2str(round(1000*t_short(Edges(Indx_F)))), ')' ], ...
            'FontSize', 14, 'FontName', FontName)
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
