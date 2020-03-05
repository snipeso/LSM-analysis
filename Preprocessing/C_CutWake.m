
%% Choose a file

Path = 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG\Session2';
Filename = 'P02_Session2.set';


EEG = pop_loadset('filename', Filename, 'filepath', Path);


%% plot all
CURRENTSET = 1;
ALLEEG(1) = EEG;
pop_eegplot(EEG, 1, 1, 0)

eegplot(EEG)

function disp1
pop_select

disp(1)
end

%% remove a channel

% choose either a specific file, or a random new one

% function to plot a given dataset, with prev markings if exist, save the markings to a file

%% remove cut data

% remove channels entirely, 
