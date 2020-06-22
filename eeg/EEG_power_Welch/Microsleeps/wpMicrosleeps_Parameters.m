

Tasks = {'LAT'}; % {'LAT', 'PVT'};

run(fullfile(extractBefore(mfilename('fullpath'), 'Microsleeps'), 'wp_Parameters'))

Refresh = false;

Paths = struct();

for Indx_T = 1:numel(Tasks)
    
    %%% Locations
    Paths(Indx_T).EEGdata = fullfile(Paths(Indx_T).Preprocessing, 'Interpolated\', Task);
    Paths(Indx_T).Figures = fullfile(Paths(Indx_T).Figures, Task);
    Paths(Indx_T).powerdata = fullfile(Paths(Indx_T).Preprocessing, 'WelchPower', Task);
    Paths(Indx_T).Cuts = fullfile(Paths(Indx_T).Preprocessing, 'Cuts\', Task);
    
    
    if ~exist(Paths(Indx_T).powerdata, 'dir') % TODO, move to appropriate location
        mkdir(Paths(Indx_T).powerdata)
    end
    
    %%% Get data
    
    % get welch power
    Paths(Indx_T).FFT = fullfile(Paths(Indx_T).wp, 'wPower', [Task, '_FFT.mat']);
    if ~exist(Paths(Indx_T).FFT, 'file') || Refresh
        [allFFT, Categories] = LoadAllFFT(Paths(Indx_T).powerdata);
        save(Paths(Indx_T).FFT, 'allFFT', 'Categories')
    else
        load(Paths(Indx_T).FFT, 'allFFT', 'Categories')
    end
    
    % get microsleep data
    
end

Chanlocs = allFFT(1).Chanlocs;
Freqs = allFFT(1).Freqs;
TotChannels = size(Chanlocs, 2);