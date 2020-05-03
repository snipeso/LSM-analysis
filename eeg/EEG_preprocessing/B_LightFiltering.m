% resorts files by relevant folder, and gently filters things so they can
% be marked for cutting and sleep scoring.

% close all
clc
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;
SpotCheck = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EEG_Parameters


% initiate log
StartTime = datestr(now, 'yy-mm-dd_HH-MM');
m = matfile(fullfile(Paths.Logs, [StartTime, '_B_Log.mat']),'Writable',true);


allLog = struct();
for Indx_D = 1:size(Folders.Datasets,1) % loop through participants
    Log = struct();
    for Indx_F = 1:size(Folders.Subfolders, 1) % loop through all subfolders
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        %%% Check if data exists
        
        Path = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, Folders.Subfolders{Indx_F});
        
        % skip rest if folder not found
        if ~exist(Path, 'dir')
            Log(Indx_F).path = Path;
            Log(Indx_F).info = 'missing';
            Log(Indx_F).reason = 'no path';
            warning([deblank(Path), ' does not exist'])
            continue
        end
        
        % identify menaingful folders traversed
        Levels = split(Folders.Subfolders{Indx_F}, '\');
        Levels(cellfun('isempty',Levels)) = []; % remove blanks
        Levels(strcmpi(Levels, 'EEG')) = []; % remove uninformative level that its an EEG
        
        Task = Levels{1};
        
        % if does not contain EEG, then skip
        Content = ls(Path);
        SET = contains(string(Content), '.set');
        if ~any(SET)
            if any(strcmpi(Levels, 'EEG')) % if there should have been an EEG file, be warned
                Log(Indx_F).path = Path;
                Log(Indx_F).info = 'missing';
                Log(Indx_F).reason = 'no set file';
                
                warning([Path, ' is missing SET file'])
            end
            continue
        elseif nnz(SET) > 1 % if there's more than one set file, you'll need to fix that
            Log(Indx_F).path = Path;
            Log(Indx_F).info = 'skipping';
            Log(Indx_F).reason = 'more than one set file';
            warning([Path, ' has more than one SET file'])
            continue
        end
        
        Filename_SET = Content(SET, :);
        
        % set up destination location
        Destination = fullfile(Paths.LFiltered, Task);
        Filename_Core = join([Folders.Datasets{Indx_D}, Levels(:)'], '_');
        Filename_Destination = [Filename_Core{1}, '.set'];
        
        if ~exist(Destination, 'dir')
            mkdir(Destination)
        end
        
        % skip filtering if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            Log(Indx_F).path = Path;
            Log(Indx_F).info = 'skipping';
            Log(Indx_F).reason = 'already done';
            disp(['***********', 'Already did ', Filename_Core, '***********'])
            continue
        end
        
        %%%%%%%%%%%%%%%%%%%
        %%% filter the data
        
        EEG = pop_loadset('filepath', Path, 'filename', Filename_SET);
        
        SpotCheckOriginals = EEG.data(CheckChannels, :);
        originalFS = EEG.srate;
        
        try
%             
            % low-pass filter
            EEG = pop_eegfiltnew(EEG, [], low_pass);
            
                        % notch filter for line noise
            EEG = lineFilter(EEG, 50, false);
            

            
            % high-pass filter. NOTE: this is different from LP on purpose
            EEG = hpEEG(EEG, high_pass, hp_stopband);
            
            EEG = eeg_checkset(EEG);
            
        catch
            Log(Indx_F).path = Path;
            Log(Indx_F).info = 'skipping';
            Log(Indx_F).reason = 'failed to filter';
            
            warning(['could not clean ', Filename_SET])
            continue
        end
        
        % randomly check some of the datasets to make sure things look ok
        if SpotCheck && randi(SpotCheckFrequency) == 1
            SpotCheckFiltered = EEG.data(CheckChannels, :);
            
            % time vectors
            tO = linspace(0, size(SpotCheckOriginals, 2)/originalFS, size(SpotCheckOriginals, 2));
            tF = linspace(0, size(SpotCheckFiltered, 2)/EEG.srate, size(SpotCheckFiltered, 2));
            
            figure
            for Indx_Ch = 1:numel(CheckChannels) % plot a subplot for each channel
                subplot(numel(CheckChannels), 1, Indx_Ch)
                hold on
                plot(tO, SpotCheckOriginals(Indx_Ch, :), 'k')
                plot(tF, SpotCheckFiltered(Indx_Ch, :), 'r')
                title([Filename_Destination, ' ', num2str(CheckChannels(Indx_Ch))])
            end
            
            fs = EEG.srate;
            figure
            for Indx_Ch = 1:numel(CheckChannels) % plot a subplot for each channel
                subplot(numel(CheckChannels), 1, Indx_Ch)
                hold on
                
                x = SpotCheckOriginals(Indx_Ch, :);
                [pxx,f] = pwelch(x,length(x),[],length(x),fs);
                plot(f, log(pxx), 'k')
                x =  SpotCheckFiltered(Indx_Ch, :);
                [pxx,f] = pwelch(x,length(x),[],length(x),fs);
                plot(f, log(pxx), 'r')
                title([ 'FFT ', Filename_Destination, ' ', num2str(CheckChannels(Indx_Ch))])
            end
            
            
        end
        
        EEG.setname = [extractBefore(EEG.filename, '.set'), '_LF'];
        pop_saveset(EEG, 'filename', Filename_Destination, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        Log(Indx_F).path = Path;
        Log(Indx_F).info = 'converted';
        Log(Indx_F).reason = ['everything was ok with ', Filename_SET];
    end
    
    allLog(Indx_D).log = Log;
    disp(['************** Finished ',  Folders.Datasets{Indx_D}, '***************'])
    m.log = allLog;
    
end

