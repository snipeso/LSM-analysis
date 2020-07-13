Path = 'C:\Users\colas\Desktop\LSMData\Microsleeps\MAT\PVT\';
All = ls(Path);
All(~contains(string(All), '.mat'), :) = [];

for Indx = 1:size(All, 1)
    load(fullfile(Path, All(Indx, :)))
    disp(All(Indx, :))
    disp(ChosenChannels)
    
end