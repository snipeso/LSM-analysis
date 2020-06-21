function [EEGdata, srate] = LoadEGI(Filepath, Channels)
% function for loading EGI ".raw" files. This assumes that the only raw
% files in the given folder are related to the same night of sleep.

Raw_Files = ls(Filepath); % list all content
Raw_Files(~contains(Raw_Files, '.raw'), :) = []; % remove all files that aren't raw
Tot_Raw = size(Raw_Files, 1);

%%% get's sampling rate from the header

fid = fopen(Raw_Files(1, :),'rb','b');
[~, ~, ~, ~,srate, ~, ~, ~, ~] = readRAWFileHeader(fid);
fclose(fid);


%%% load EEG data

EEGdata = [];
Start = 1;
wb = waitbar(0, 'Load .raw files ...');
for Indx = 1:Tot_Raw
    
     % load the EEG data (which is in .raw files)
    EEG_1h  = loadEGIBigRaw(Raw_Files(Indx, :), Channels);
    Stop = size(EEG1h, 2) + Start - 1;
    
    EEGdata(:, Start:Stop) = EEG_1h; % this appends the data without using too much RAM
    Start = Stop + 1;
    
     % update waitbar
    waitbar(Indx/Tot_Raw, wb, 'Load .raw files ...');
end

close(wb); 
