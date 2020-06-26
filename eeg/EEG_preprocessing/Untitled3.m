% eeglab
close all

        ALLCOM =[];
        ALLEEG = EEG;
        CURRENTSET = 0;
        CURRENTSTUDY = 0;
EEG = pop_loadset('filename', 'P01_LAT_BaselineBeam_ICA_Components.set', 'filepath', 'C:\Users\schlaf\Desktop\LSMData\ICA\Components\LAT');
pop_selectcomps(EEG, [1:35]);