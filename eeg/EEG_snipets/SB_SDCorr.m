clear
clc
close all

run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))

CAxis = [0 1];
Filepath = 'C:\Users\colas\Desktop\Temp';

ICTopos = [];

Sessions = {'BL', 'Pre', 'SD1', 'SD2-1', 'SD2-2', 'SD2-3', 'Post'};

Filename = 'P08_LAT_BaselineBeam_ICA_Components.set';
EEG = pop_loadset('filename', Filename, 'filepath', Filepath);
FrontIC = 3;
Weights = EEG.icaweights*EEG.icasphere;
ICAEEG = Weights * EEG.data;
IC1 = ICAEEG(FrontIC, :);
ICTopo =  EEG.icawinv(:, FrontIC);
   figure('units','normalized','outerposition',[0 0 .15 .3])
    topoplot(ICTopo, EEG.chanlocs, 'style', 'map', 'headrad', 'rim', 'gridscale', 300);
    colormap(Format.Colormap.Divergent)
    title(Sessions{1})
    set(gca, 'FontName', Format.FontName, 'FontSize', 14)

Filename = 'P08_LAT_MainPre_ICA_Components.set';
EEG = pop_loadset('filename', Filename, 'filepath', Filepath);
FrontIC = 14; % if not good; try 23
Weights = EEG.icaweights*EEG.icasphere;
ICAEEG = Weights * EEG.data;
IC2 = ICAEEG(FrontIC, :);
ICTopo =  EEG.icawinv(:, FrontIC);
   figure('units','normalized','outerposition',[0 0 .15 .3])
    topoplot(ICTopo, EEG.chanlocs, 'style', 'map', 'headrad', 'rim', 'gridscale', 300);
    colormap(Format.Colormap.Divergent)
    title(Sessions{2})
    set(gca, 'FontName', Format.FontName, 'FontSize', 14)

Filename = 'P08_LAT_Session1Beam_ICA_Components.set';
EEG = pop_loadset('filename', Filename, 'filepath', Filepath);
FrontIC = 9;
Weights = EEG.icaweights*EEG.icasphere;
ICAEEG = Weights * EEG.data;
IC3 = ICAEEG(FrontIC, :);
ICTopo =  EEG.icawinv(:, FrontIC);
   figure('units','normalized','outerposition',[0 0 .15 .3])
    topoplot(ICTopo, EEG.chanlocs, 'style', 'map', 'headrad', 'rim', 'gridscale', 300);
    colormap(Format.Colormap.Divergent)
    title(Sessions{3})
    set(gca, 'FontName', Format.FontName, 'FontSize', 14)

Filename = 'P08_LAT_Session2Beam1_ICA_Components.set';
EEG = pop_loadset('filename', Filename, 'filepath', Filepath);
FrontIC = 10;
Weights = EEG.icaweights*EEG.icasphere;
ICAEEG = Weights * EEG.data;
IC4 = ICAEEG(FrontIC, :);
ICTopo =  EEG.icawinv(:, FrontIC);
   figure('units','normalized','outerposition',[0 0 .15 .3])
    topoplot(ICTopo, EEG.chanlocs, 'style', 'map', 'headrad', 'rim', 'gridscale', 300);
    colormap(Format.Colormap.Divergent)
    title(Sessions{4})
    set(gca, 'FontName', Format.FontName, 'FontSize', 14)

Filename = 'P08_LAT_Session2Beam2_ICA_Components.set';
EEG = pop_loadset('filename', Filename, 'filepath', Filepath);
FrontIC = 14;
Weights = EEG.icaweights*EEG.icasphere;
ICAEEG = Weights * EEG.data;
IC5 = ICAEEG(FrontIC, :);
ICTopo =  EEG.icawinv(:, FrontIC);
   figure('units','normalized','outerposition',[0 0 .15 .3])
    topoplot(ICTopo, EEG.chanlocs, 'style', 'map', 'headrad', 'rim', 'gridscale', 300);
    colormap(Format.Colormap.Divergent)
    title(Sessions{5})
    set(gca, 'FontName', Format.FontName, 'FontSize', 14)


Filename = 'P08_LAT_Session2Beam3_ICA_Components.set';
EEG = pop_loadset('filename', Filename, 'filepath', Filepath);
FrontIC = 9;
Weights = EEG.icaweights*EEG.icasphere;
ICAEEG = Weights * EEG.data;
IC6 = ICAEEG(FrontIC, :);
ICTopo =  EEG.icawinv(:, FrontIC);
   figure('units','normalized','outerposition',[0 0 .15 .3])
    topoplot(ICTopo, EEG.chanlocs, 'style', 'map', 'headrad', 'rim', 'gridscale', 300);
    colormap(Format.Colormap.Divergent)
    title(Sessions{6})
    set(gca, 'FontName', Format.FontName, 'FontSize', 14)

Filename = 'P08_LAT_MainPost_ICA_Components.set';
EEG = pop_loadset('filename', Filename, 'filepath', Filepath);
FrontIC = 3;
Weights = EEG.icaweights*EEG.icasphere;
ICAEEG = Weights * EEG.data;
IC7 = ICAEEG(FrontIC, :);
ICTopo =  EEG.icawinv(:, FrontIC);
   figure('units','normalized','outerposition',[0 0 .15 .3])
    topoplot(ICTopo, EEG.chanlocs, 'style', 'map', 'headrad', 'rim', 'gridscale', 300);
    colormap(Format.Colormap.Divergent)
    title(Sessions{7})
    set(gca, 'FontName', Format.FontName, 'FontSize', 14)


ICAll = [IC1, IC2, IC3, IC4, IC5, IC6, IC7];
[R, Windows] = SnipletCorrelation(ICAll, 5*EEG.srate, .5, true);
figure('units','normalized','outerposition',[0 0 1 1])
imagesc(R)
colorbar
colormap(Format.Colormap.Linear)
caxis(CAxis)

