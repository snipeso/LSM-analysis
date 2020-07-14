
hb_Parameters

Task = 'PVT';
Participant = 'P04';
Session = 'Session2Beam';
Filename = [Participant, '_', Task, '_', Session, '_Clean.set' ];
% Title = Filename;
Title = 'ThetaEvent';
StartTime = 150;
EndTime = 153;

Filepath = fullfile(Paths.Preprocessed, 'Interpolated', 'Set', Task);

EEG = pop_loadset('filename', Filename, 'filepath', Filepath);
[HilbertPower, Phase] = HilbertBands(EEG, Bands, BandNames, 'matrix');


MakePowerGIF('C:\Users\schlaf\Desktop', Title, HilbertPower, BandNames,...
    EEG.chanlocs, StartTime, EndTime,  EEG.srate, 20, 2, Colormap.Linear, FontName)



MakePowerGIF('C:\Users\schlaf\Desktop', [Title, '_log'], log(HilbertPower), BandNames,...
    EEG.chanlocs, StartTime, EndTime,  EEG.srate, 20, 2, Colormap.Linear, FontName)