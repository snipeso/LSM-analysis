function SaveScoring(Destination, Name, ScoringData, sp1, sp2)
% Saves the matrix ScoringData such that:
% row 1: EMG
% row 2: EOG1
% row 3: EOG2
% row 4&5: F3,4
% row 6&7: C3,4
% row 8&9: O1,2
% if you have different inputs, you'll need to change the header template

% limit filename size
if length(Name) > 15 % there is a limit to the size of the filename, I'm just guessing that 15 characters is ok
    Name = Name(1:15);
    warning(['had to shorten name to: ', Name])
end

% Create folder for sleepscoring file, with software for scoring it
Destination = fullfile(Destination, Name);
copyfile(fullfile(cd, 'ScoringFunctions', 'ScoringProgramTemplate/'), Destination)

% rename header file
movefile(fullfile(Destination, 'Template_Header.HDR'), fullfile(Destination, [Name, '.HDR'])) % fancy?

% save eeg data
fid = fopen(fullfile(Destination, [Name, '.r09']), 'w');
fwrite(fid, ScoringData, 'short')
fclose(fid);

% save sp1
fid = fopen(fullfile(Destination, [Name, '.sp1']), 'w');
fwrite(fid, sp1, 'float')
fclose(fid);

% save sp2
fid = fopen(fullfile(Destination, [Name, '.sp2']), 'w');
fwrite(fid, sp2, 'float')
fclose(fid);


% TODO:
% - make second sp optional
% - make flexible to make a .r04 file when running on SleepLoop data if
% that's what gets inputted