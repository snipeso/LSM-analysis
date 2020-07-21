
hb_Parameters

Task = 'PVT';
Participant = 'P12';
Session = 'Session2Beam';
Filename = [Participant, '_', Task, '_', Session, '_Clean.set' ];
% Title = Filename;
Title = 'Theta';
StartTime = 183;
EndTime = 187;

Filepath = fullfile(Paths.Preprocessed, 'Interpolated', 'Set', Task);

EEG = pop_loadset('filename', Filename, 'filepath', Filepath);
[HilbertPower, Phase] = HilbertBands(EEG, Bands, BandNames, 'matrix');


MakePowerGIF('C:\Users\colas\Desktop', Title, HilbertPower, BandNames,...
    EEG.chanlocs, StartTime, EndTime,  EEG.srate, 20, 2, Format.Colormap.Linear, Format.FontName)


% 
% MakePowerGIF('C:\Users\colas\Desktop', [Title, '_log'], log(HilbertPower), BandNames,...
%     EEG.chanlocs, StartTime, EndTime,  EEG.srate, 20, 2, Format.Colormap.Linear, Format.FontName)