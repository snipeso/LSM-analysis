
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))

Window = 30;
Overlap = .33;
Taper = true;

Path = 'C:\Users\colas\Desktop\Temp\P09_Sleep_Baseline';

Content = string(ls(Path));
Content(~contains(Content, '.vis')) = [];
Filename = deblank(Content(1));

visfilename = fullfile(Path, Filename);
[vistrack, vissymb, offs] = visfun.readtrac(visfilename, 1);

[visnum] = visfun.numvis(vissymb, offs);
% [visplot] = visfun.plotvis(visnum, 10);

Legend = {
1, 'w';
0, 'r';
-1, 'n1';
-2, 'n2';
-3, 'n3'
};


Filename = 'P09_Sleep_Baseline_Scoring.set';
Filepath = 'C:\Users\colas\Desktop\Temp';
EEG = pop_loadset('filename', Filename, 'filepath', Filepath);

EEG = pop_reref(EEG, []);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% correlation across channels

% Ch = [11, 124, 117, 104,  98, 90, 83, 75, 70, 65, 47, 36, 28, 24];

% Ch = [15, 9 2 122 115 108 101 96 90 83 75 70 65 58 50 45 39 33 26 22];

% Ch = [11, 4, 124, 117, 110, 103, 98, 92, 85, 77, 72, 67, 60, 52, 47, 41, 35, 28, 24, 19];

% Ch = [4 124 104 103 98, 92, 90, 83, 75, 70, 65, 52, 47, 41, 36, 24, 19, 11];
% 
% Ch = flip(Ch);

Ch = 1:128;

DAllCh = [];
for Indx_Ch = 1:numel(Ch)
    [R, Windows] = SnipletCorrelation(EEG.data(Ch(Indx_Ch), :), Window*EEG.srate, Overlap, Taper);
    DAllCh = cat(1, DAllCh, squareform(1-R));
end

% get stages per window
RPoints = size(DAllCh, 2);
StagePoints = round(linspace(1, numel(visnum), RPoints)); % associate point of stages for every r value
RStages = nan(1, RPoints);
for Indx_P = 1:RPoints
    RStages(Indx_P) = visnum(StagePoints(Indx_P));
end


% whole recording
R = corrcoef(DAllCh');
Table = [];
for Indx_Ch1 = 1:numel(Ch)-1
   for Indx_Ch2 = Indx_Ch1+1:numel(Ch) 
       Table = cat(1, Table, [Ch(Indx_Ch1), Ch(Indx_Ch2), R(Indx_Ch1, Indx_Ch2)]);
   end
end


Table = array2table(Table);
 Table.Table1 =  string(Table.Table1);
  Table.Table2 =  string(Table.Table2);
  
% figure
% Plot_Nodes(Table, string(Ch), [0.6, 1], 30)

Chanlocs = EEG.chanlocs;
Chanlocs = Chanlocs(Ch);
figure
PlotTopoNodes(R, [.6 1], Chanlocs)

% by sleep stage







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% correlation across stages






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assmeble "average per stage", run on 2 channels, and see when there's
% most disagreement?





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% maxclustering












