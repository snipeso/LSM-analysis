
Clustering_Parameters

% Participant = 'P01';
% Task = 'LAT';
% Folder = 'ICA';
% Session = 'Session2Beam1';
% KeepComponents = 6;

% Session = 'BaselineComp';
% KeepComponents = 11;

Participant = 'P08';
Task = 'MWT';
Folder = 'ICA';
Session = 'Main';
KeepComponents = 2;

Filename = [strjoin({Participant, Task, Session, Folder, 'Components'}, '_'),...
    '.set'];
Filepath = fullfile(Paths.Preprocessed, Folder, 'Components', Task);
EEG = pop_loadset('filename', Filename, 'filepath', Filepath);


badcomps = 1:size(EEG.icaweights, 1);
badcomps(KeepComponents) = [];
NewEEG = pop_subcomp(EEG, badcomps);

Data1 = EEG.data;
Data2 = NewEEG.data;

Range = 1;
Data2(abs(Data2)<Range) = nan;



  Weights = EEG.icaweights*EEG.icasphere;
 ICAEEG = Weights * EEG.data;
 t = linspace(0, EEG.pnts/EEG.srate, EEG.pnts);
 figure
 plot(t, ICAEEG(KeepComponents, :))
 
 

Pix = get(0,'screensize');

eegplot(Data1, 'srate', EEG.srate, 'spacing', 25, 'winlength', 10, 'data2', Data2)


eegplot(Data2, 'srate', EEG.srate, 'spacing', 10, 'winlength', 10)
