% script that gets power values of little segments of data
clear
clc
close all


Refresh = true;
wp_Parameters

Files = deblank(cellstr(ls(Paths.EEGdata)));
Files(~contains(Files, '.set')) = [];

for Indx_F = 1:numel(Files)
%     File = Files{Indx_F};
File = 'P03_LAT_Extras_ICAd.set';
    Filename = [extractBefore(File, '.set'), '_wp.mat'];
    
    if ~Refresh && exist(fullfile(Paths.powerdata, Filename), 'file')
        disp(['**************already did ',Filename, '*************'])
        continue
    end
    EEG = pop_loadset('filename', File, 'filepath', Paths.EEGdata);
    
    % remove bad channels
    EEG = pop_select(EEG, 'nochannel', notEEG);
    
    % remove start and stop
    StartPoint = EEG.event(strcmpi({EEG.event.type}, StartMain)).latency;
    EndPoint =  EEG.event(strcmpi({EEG.event.type}, EndMain)).latency;
    EEG.data(:, [1:round(StartPoint),  round(EndPoint):end]) = nan;
    
    
    % set to nan all cut data
    Cuts_Filepath = fullfile(Paths.Cuts, [extractBefore(File, '_ICA'), '_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);
    
    
    
    
    % TODO: create welchspectrum function that takes EEG and edges, so can
    % run over and over
    [Channels, Points] = size(EEG.data);
    fs = EEG.srate;

    Epochs = Points/(fs*Window);
    Starts = floor(linspace(1, Points - fs*Window, Epochs));
    Stops = floor(Starts + fs*Window);
    Edges = [Starts(:), Stops(:)];
    
    General = WelchSpectrum(EEG, Freqs, Edges);
    
    % run epochs of all data, shifting boarders to accomodate noise (if > .5, cut short, if <.5, skip)
    % called General (with FFT, and Edges as fields)
    
    % run over blocks, called Blocks
    
    % run over trials Trials(each trial), with field preFFT, postFFT,
    % number,block number
    
    
    
    
    parsave(fullfile(Paths.powerdata, Filename), FFT, Freqs, EEG.chanlocs) %TODO save sever
    disp(['*************finished ',Filename '*************'])
    
end


function parsave(fname, FFT)
save(fname, 'FFT')
end