clear
clc
close all
EEG_Parameters


Filename = [];


Source = fullfile(Paths.Preprocessed, 'Cleaning', 'SET', Folder);
Destination = fullfile(Paths.Preprocessed, 'Cleaning', 'Cuts', Folder);


EEG = pop_loadset('filename', Filename, 'filepath', Source);