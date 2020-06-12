% script for splitting apart the EEG of the RRTs, which are saved in the
% same file, divided only by triggers.

clear
clc
close all

EEG_Parameters
Refresh = false;
Padding = 5; % time around the events to keep in cut

StartFixCode = 'S 12';
EndFixCode = 'S 13';
StartStandCode = 'S 14';
EndStandCode = 'S 15';

% get list of folders for RRTs
Folders.RRT = cellstr(ls(fullfile(Paths.Datasets, Folders.Template, 'Fixation')));
Folders.RRT(contains(Folders.RRT, '.')) = [];

StartTime = datestr(now, 'yy-mm-dd_HH-MM');

for Indx_D = 1:size(Folders.Datasets,1) % loop through participants
    
    for Indx_F = 1:numel(Folders.RRT)
        Paths_Fixation = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, ...
            'Fixation', Folders.RRT{Indx_F}, 'EEG');
        Paths_Standing =  fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, ...
            'Standing', Folders.RRT{Indx_F}, 'EEG');
        Paths_Oddball =  fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, ...
            'Oddball', Folders.RRT{Indx_F}, 'EEG');
        
        Paths_QuestionnaireEEG = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, ...
            'QuestionnaireEEG', Folders.RRT{Indx_F}, 'EEG');
        
        if ~exist(Paths_QuestionnaireEEG, 'dir')
            mkdir(Paths_QuestionnaireEEG)
        end
        
        
        % skip rest if folder not found
        if ~exist(Paths_Fixation, 'dir')
            warning([deblank(Paths_Fixation), ' does not exist'])
            continue
        end
        
        % if does not contain EEG, then skip
        if ~CheckSet(Paths_Fixation)
            continue
        end
        
        
Content = contains(string(ls(Path)), '.set');
        Filename.SET = Content(SET, :);
        
        % if not going to refresh and file already split, skip
        if ~Refresh && CheckSet(Paths_Standing) && CheckSet(Paths_Oddball) ...
                && CheckSet(Paths_QuestionnaireEEG)
            disp(['****** Skipping ', Filename.SET, ' *******'])
            continue
        end
        
        
        
        EEG = pop_loadset('filename', Filename.SET, 'filepath', Paths_Fixation);
        
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
                'filepath', Paths_Fixation, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');
        catch
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
                'filepath', Paths_Standing, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');
        catch
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
                'filepath', Paths_Oddball, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');
        catch
            warning(['couldnt make oddball file for ', Filename.SET]) % TODO: add to log
        end
        
        
        try
            StartQ = EndOddball + EEG.srate*Padding;
            EndQ = StartStand -  EEG.srate*Padding;
            
            % cut
            EEGQ = pop_select(EEG, 'point', [StartQ, EndQ]);
            
            % save
            pop_saveset(EEGQ, 'filename', ['Questionnaire_', Filename.SET], ...
                'filepath', Paths_QuestionnaireEEG, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');
        catch
            warning(['couldnt make questionnaire file for ', Filename.SET]) % TODO: add to log
        end
    end
end


function IsPresent = CheckSet(Path)
% checks if there is a set file in the folder

IsPresent = false;
Content = ls(Path);
SET = contains(string(Content), '.set');

if ~any(SET)
    warning([Paths_Fixation, ' is missing EEG files'])
elseif nnz(SET) > 1
    warning([Paths_Fixation, ' has more than one eeg file'])
else
    IsPresent = true;
end


end