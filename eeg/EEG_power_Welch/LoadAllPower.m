function [PowerStruct, Chanlocs, Freqs] = LoadAllPower(Path, Participants, Condition, SessionLabels, Format)

Tasks = Format.Tasks.(Condition);

PowerStruct = struct();

for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};
    AllFiles = string(ls(fullfile(Path, Task)));
    Sessions = Format.Labels.(Task).(Condition).Sessions;
    
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            
            File = AllFiles(contains(AllFiles, strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}}, '_')), :);
            
            
            if isempty(File)
                warning(['No power for ', strjoin({Participants{Indx_P}, Task, Sessions{Indx_S}}, '_')])
                FFT = [];
            else
                load(fullfile(Path, Task, File), 'Power')
                FFT = Power.FFT;
            end
            
            PowerStruct(Indx_P).(Task).(SessionLabels{Indx_S}) = FFT;
        end
    end
end

Chanlocs = Power.Chanlocs;
Freqs = Power.Freqs;
