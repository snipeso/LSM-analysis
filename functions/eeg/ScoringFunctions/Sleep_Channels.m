function Sleep_Ch = Sleep_Channels()
% select which channels of your data refer to the following channels
F3 = 24; % these are the channels of the high density net that we use for scoring
F4 = 124;
C3 = 36;
C4 = 104;
O1 = 70;
O2 = 83;
M1 = 57;
M2 = 100;
EOG1L = 128;
EOG1R = 1;
EOG2L = 125;
EOG2R = 32;
EMG = [107, 113];


% Assemble channel indices into correct order
Sleep_Ch = [F3, F4, C3, C4, O1, O2, M1, M2, EOG1L, EOG1R, EOG2L, EOG2R, EMG];

