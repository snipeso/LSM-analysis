clear
close all
clc
Refresh = false;
GeneralPreprocessingParameters
Folder_SleepScoring = 'SleepScoring';

f3    = 24;
f4    = 124;
c3    = 36;
c4    = 104;
o1    = 70;
o2    = 83;
a1    = 56;% original 57
a2    = 49; % original 100
eogbottomL = 128;
eogbottomR = 125; % original 1
eogtopL = 25; % original 125
eogtopR = 8; % original 32
emgL  = 107;
emgR  = 113;
ndxch = [f3, f4, c3, c4, o1, o2, a1, a2, eogbottomL, eogbottomR, eogtopL, eogtopR, emgL, emgR]; % original


for Indx_D = 1:size(Folders.Datasets,1) % loop through participants
    
    parfor Indx_F = 1:size(Folders.Subfolders, 1) % loop through all subfolders
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        %%% Check if data exists
        
        Path = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, Folders.Subfolders{Indx_F});
        
        % skip rest if folder not found
        if ~exist(Path, 'dir')
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
                warning([Path, ' is missing SET file'])
            end
            continue
        elseif nnz(SET) > 1 % if there's more than one set file, you'll need to fix that
            warning([Path, ' has more than one SET file'])
            continue
        end
        
        Filename_SET = Content(SET, :);
        
        % set up destination location
        Destination = fullfile(Paths.Preprocessed, Folder_SleepScoring, Task);
        Filename_Core = extractBefore(Filename_SET, '.set');
        
        if ~exist(Destination, 'dir')
            mkdir(Destination)
        end
        
        % skip if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Core, '***********'])
            continue
        end
        
        %%%%%%%%%%%%%%%%%%%
        %%% convert the data
        
        EEG = pop_loadset('filepath', Path, 'filename', Filename_SET);
        
        f3a2  = EEG.data(f3, :) - EEG.data(a2, :);
        f4a1  = EEG.data(f3, :) - EEG.data(a1, :);
        c3a2  = EEG.data(c3, :) - EEG.data(a2, :);
        c4a1  = EEG.data(c4, :) - EEG.data(a1, :);
        o1a2  = EEG.data(o1, :) - EEG.data(a2, :);
        o2a1  = EEG.data(02, :) - EEG.data(a1, :);
        eog1  = EEG.data(eogbottomL, :) - EEG.data(eogtopR, :);
        eog2  = EEG.data(eogbottomR, :) - EEG.data(eogtopL, :);
        emg   = EEG.data(emgL, :) - EEG.data(emgR, :);
        
        EEGscore =[emg; eog1; eog2; f3a2; f4a1; c3a2; c4a1; o1a2; o2a1];
        
        % write .r09 file
        fprintf('--- Saving %s ...\n', [basename, '.r09'])
        fid = fopen([basename, '.r09'], 'w');
        fwrite(fid,scorblock,'short')
        fclose(fid);
        
        %%% .sp1
        
        % do the spectral analysis for C3A2 (change channel if needed)
        c3a2 = double(scorblock(6, :));  % FFT requires numbers in double format
        
        % number of 4s epochs in the data
        pnts     = size(c3a2, 2);
        numepo4s = floor(pnts/srate_dwn/4);
        
        % preallocate to boost speed
        FFTout   = NaN(30, numepo4s);
        SP2      = NaN(4,  numepo4s);
        % spectral analysis for C3A2
        wb = waitbar(0, 'Spectral power analysis ...'); tic
        for epo = 1:numepo4s
            
            % sample points in each 4s window
            from              = (epo-1)*4*srate_dwn+1;
            to                = (epo-1)*4*srate_dwn+4*srate_dwn;
            
            % spectral analysis in 4s windows (just as the scoring programm needs it)
            % with a hanning window, zero overlap, for 1 to 512 Hz bins, and
            % specify the sampling rate.
            [fft_epoch, freq] = pwelch(c3a2(from:to), hanning(4*srate_dwn), 0, 4*srate_dwn, srate_dwn);
            
            % frequencies of interest
            index30 = freq<30;
            index4  = freq>=0.5 & freq<=4;
            index16 = freq>=11  & freq<=16;
            index13 = freq>=8   & freq<=13;
            index40 = freq>=20  & freq<=40;
            
            % take power values for frequencies up to 30 Hz (ffte(1:120) and
            % take the mean of 4 neoughbouring frequency bins eachs (still only
            % up to 30 Hz). Must have 30 rows, corresponds to one power-bar in a
            % 4s window in the scoring programm
            fft30  = mean(reshape(fft_epoch(index30), 4, 30));
            freq30 = mean(reshape(freq(index30), 4, 30)); % if you are interested in
            % the frequency bins used for the power calculation
            
            % Power in delta, sigma, alpha and beta-gamma range (needed for the
            % vigilance index, which is stored in .sp2.
            SP2(1, epo) = mean(fft_epoch(index4));    % delta
            SP2(2, epo) = mean(fft_epoch(index16));   % sigma (spindles)
            SP2(3, epo) = mean(fft_epoch(index13));   % alpha
            SP2(4, epo) = mean(fft_epoch(index40));   % beta-gamma
            
            % concatenate 4s epochs.
            FFTout(:, epo) = fft30;
            waitbar(epo/numepo4s, wb, 'Spectral power analysis ...');
        end
        close(wb)
        
        % write sp1 file
        fprintf('--- Saving %s ...\n', [basename, '.sp1'])
        fid = fopen([basename, '.sp1'],'w');
        fwrite(fid, FFTout, 'float');
        fclose(fid);
        
        %%% .sp2 (Vigilance Index)
        
        
        % Calculate modified Vigilance Index (with emphasis on spindles). The idea
        % came from Elena Krugliakova (thank you!). It is based on this article:
        % https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5455770/?fbclid=IwAR22XbpTGq2LsOiQGeNwZujvLiZ_aNGvFPwn65iAClTAn5yUgtMjFYQiPbg
        % VI = [delta power norm + 2*spindle power norm] / ...
        %      [alpha power norm + high-beta power norm]
        % Frequency ranges used were delta (1–4 Hz),  spindle (11–16Hz),
        %                            alpha (8–13 Hz), high-beta (20–40 Hz)
        VI = (SP2(1,:)./median(SP2(1,:))  +  SP2(2,:)./median(SP2(2,:)).*2) ./ ...
            (SP2(3,:)./median(SP2(3,:))  +  SP2(4,:)./median(SP2(4,:)));
        
        % Reshape VI, so that each 4s epoch has the same value 30x (otherwise the
        % scoring programm cannot read it).
        VI30 = repmat(VI, 30, 1);
        
        % write sp2 file
        fprintf('--- Saving %s ...\n', [basename, '.sp2'])
        fid = fopen([basename, '.sp2'],'w');
        fwrite(fid, VI30, 'float');
        fclose(fid);
        
        
    end
    
end

