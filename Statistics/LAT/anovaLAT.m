clear
clc
close all


Stats_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DataPath = fullfile(Paths.Analysis, 'Statistics', 'LAT', 'Data'); % for statistics

% Data type
Type = 'Motivation';
Loggify = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



load(fullfile(DataPath, ['LAT_', Type, '_Classic.mat']))
if Loggify
    Matrix = log(Matrix);
end
Classic = mat2table(Matrix, Participants, {'s1', 's2', 's3'}, 'Participant', [], Type);


load(fullfile(DataPath, ['LAT_', Type, '_Soporific.mat']))
if Loggify
    Matrix = log(Matrix);
end
Soporific = mat2table(Matrix, Participants, {'s4', 's5', 's6'}, 'Participant', [], Type);


Between = [Classic, Soporific(:, 2:end)];

Within = table();
Within.Session = {'B'; 'S1'; 'S2'; 'B'; 'S1'; 'S2'};
Within.Condition = {'C'; 'C'; 'C'; 'S'; 'S'; 'S'};

rm = fitrm(Between,'s1-s6~1', 'WithinDesign',Within);

ranovatbl = ranova(rm, 'WithinModel', 'Session*Condition')
multcompare(rm, 'Session', 'By', 'Condition')
multcompare(rm, 'Condition', 'By', 'Session')


