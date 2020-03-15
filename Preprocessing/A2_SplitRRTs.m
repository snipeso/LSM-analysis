% script for splitting apart the EEG of the RRTs, which are saved in the
% same file, divided only by triggers.

clear
clc
close all

GeneralPreprocessingParameters
Padding = 5; % time around the events to keep in cut

StartFixCode = 'S 12';
EndFixCode = 'S 13';
StartStandCode = 'S 14';
EndStandCode = 'S 15';

% get list of folders for RRTs
Folders.RRT = cellstr(ls(fullfile(Paths.Datasets, Folders.Template, 'Fixation')));
Folders.RRT(contains(Folders.RRT, '.')) = [];

StartTime = datestr(now, 'yy-mm-dd_HH-MM');
m = matfile(fullfile(Paths.Logs, [StartTime, '_A2_Log.mat']),'Writable',true);

missing = struct();
skipped = struct();
converted = struct();


A = tic;
for Indx_D = 1:size(Folders.Datasets,1) % loop through participants
    
    for Indx_F = 1:numel(Folders.RRT)
        Paths.Fixation = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, ...
            'Fixation', Folders.RRT{Indx_F}, 'EEG');
        Paths.Standing =  fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, ...
            'Standing', Folders.RRT{Indx_F}, 'EEG');
        Paths.Oddball =  fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, ...
            'Oddball', Folders.RRT{Indx_F}, 'EEG');
        
        Paths.QuestionnaireEEG = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, ...
            'QuestionnaireEEG', Folders.RRT{Indx_F}, 'EEG');
        
        if ~exist(Paths.QuestionnaireEEG, 'dir')
            mkdir(Paths.QuestionnaireEEG)
        end
        
        
        % skip rest if folder not found
        if ~exist(Paths.Fixation, 'dir')
            missing(end + 1).path = Paths.Fixation; %#ok<SAGROW>
            missing(end).reason = 'no path';
            warning([deblank(Paths.Fixation), ' does not exist'])
            continue
        end
        
        % if does not contain EEG, then skip
        Content = ls(Paths.Fixation);
        SET = contains(string(Content), '.set');
        if ~any(SET)
            missing(end+1).path = Paths.Fixation; %#ok<SAGROW>
            missing(end).reason = 'no SET file';
            warning([Paths.Fixation, ' is missing EEG files'])
            
            continue
        elseif nnz(SET) > 1
            skipped(end + 1).path = Paths.Fixation; %#ok<SAGROW>
            skipped(end).files = Content(SET, :);
            skipped(end).reason = 'more than one SET file';
            warning([Paths.Fixation, ' has more than one eeg file'])
            continue
        end
        Filename.SET = Content(SET, :);
        
        
        EEG = pop_loadset('filename', Filename.SET, 'filepath', Paths.Fixation);
        
        try
            % get start fixation
            allEvents = {EEG.event.type};
            StartFixEvent = EEG.event(strcmpi(allEvents, StartFixCode));
            StartFix = StartFixEvent.latency - EEG.srate*Padding;
            if StartFix < 1; StartFix = 1; end
            
            % get end fixation
            EndFixEvent = EEG.event(strcmpi(allEvents, EndFixCode));
            EndFix = EndFixEvent.latency  + EEG.srate*Padding;
            
            % cut
            EEGfix = pop_select(EEG, 'point', [StartFix, EndFix]);
            
            % save
            pop_saveset(EEGfix, 'filename', Filename.SET, ...
                'filepath', Paths.Fixation, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');
        catch
            skipped(end + 1).path = Paths.Fixation; %#ok<SAGROW>
            skipped(end).files = Filename.SET;
            skipped(end).reason = 'creating fixation file failed';
            warning(['couldnt make fixation file for ', Filename.SET]) % TODO: add to log
        end
        
        try
            % get start standing
            StartStandIndx = find(strcmpi(allEvents, StartStandCode));
            StartStandEvent = EEG.event(StartStandIndx);
            StartStand = StartStandEvent.latency  - EEG.srate*Padding;
            
            % get end standing
            EndStandEvent = EEG.event(strcmpi(allEvents, EndStandCode));
            EndStand = EndStandEvent.latency  + EEG.srate*Padding;
            if EndStand > EEG.pnts; EndStand = EEG.pnts; end
            
            % cut
            EEGStand = pop_select(EEG, 'point', [StartStand, EndStand]);
            
            % save
            pop_saveset(EEGStand, 'filename', ['Stand_', Filename.SET], ...
                'filepath', Paths.Standing, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');
        catch
            
            skipped(end + 1).path = Paths.Fixation; %#ok<SAGROW>
            skipped(end).files = ['Stand_', Filename.SET];
            skipped(end).reason = 'creating stand file failed';
            
            warning(['couldnt make standing file for ', Filename.SET]) % TODO: add to log
        end
        
        try
            % get start oddball
            StartOddball = EndFixEvent.latency - EEG.srate*Padding;
            
            % get end oddball
            EndOddballIndx = StartStandIndx - 1;
            EndOddballEvent = EEG.event(EndOddballIndx);
            EndOddball = EndOddballEvent.latency + EEG.srate*Padding;
            if EndOddball > EEG.pnts; EndOddball = EEG.pnts; end
            
            % cut
            EEGOddball = pop_select(EEG, 'point', [StartOddball, EndOddball]);
            
            % save
            pop_saveset(EEGOddball, 'filename', ['Oddball_', Filename.SET], ...
                'filepath', Paths.Oddball, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');
        catch
            
            skipped(end + 1).path = Paths.Fixation; %#ok<SAGROW>
            skipped(end).files = ['Oddball_', Filename.SET];
            skipped(end).reason = 'creating oddball file failed';
            
            warning(['couldnt make oddball file for ', Filename.SET]) % TODO: add to log
        end
        
        
        try
            StartQ = EndOddball + EEG.srate*Padding;
            EndQ = StartStand -  EEG.srate*Padding;
            
            % cut
            EEGQ = pop_select(EEG, 'point', [StartQ, EndQ]);
            
            % save
            pop_saveset(EEGQ, 'filename', ['Questionnaire_', Filename.SET], ...
                'filepath', Paths.QuestionnaireEEG, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');
        catch
            warning(['couldnt make questionnaire file for ', Filename.SET]) % TODO: add to log
        end
    end
end