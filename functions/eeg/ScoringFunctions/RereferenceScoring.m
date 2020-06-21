function Scoring = RereferenceScoring(EEGdata)
% takes in: F3, F4, C3, C4, O1, O2, M1, M2, EOG1L, EOG1R, EOG2L, EOG2R, EMG
% spits out: EMG, EOG1, EOG2, F3, F4, C3, C4, O1, O2

% re-reference each channel to contralateral mastoid (except EOG and EMG)
% index info of the original channel vector:
% EEG: 1 to 6
% a1: 7
% a2: 8
% EOG: 9 to 12
% EMG: 13 to 14

F3M2    = (EEGdata(1,:)-EEGdata(8,:));
F4M1    = (EEGdata(2,:)-EEGdata(7,:));
C3M2    = (EEGdata(3,:)-EEGdata(8,:));
C4M1    = (EEGdata(4,:)-EEGdata(7,:));
O1M2    = (EEGdata(5,:)-EEGdata(8,:));
O2M1    = (EEGdata(6,:)-EEGdata(7,:));
EOG1    = (EEGdata(9,:)-EEGdata(10,:));
EOG2    = (EEGdata(11,:)-EEGdata(12,:));
EMG     = (EEGdata(13,:)-EEGdata(14,:));

% put in new order
Scoring =  [EMG; EOG1; EOG2; F3M2; F4M1; C3M2; C4M1; O1M2; O2M1];
Scoring = Scoring; % just in case data isn't already a single