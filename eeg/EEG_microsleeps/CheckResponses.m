% script for checking lapses of responses

clear
clc
% close all

Microsleeps_Parameters


Task = 'PVT';
Condition = 'Beam';
Sessions = {'Baseline', 'Session1', 'Session2'};



Sessions = strcat(Sessions, Condition);
Tot = nan(numel(Participants), numel(Sessions), 2); % tot stim, tot resp
Micro = nan(numel(Participants), numel(Sessions), 2);
RTs =  nan(numel(Participants), numel(Sessions), 2);
Source_Data = fullfile(Paths.Preprocessed, 'Interpolated', 'SET', Task);
Source_Microsleeps =  fullfile(Paths.Preprocessed, 'Microsleeps', 'Scoring', Task);


% list all files
Files = deblank(cellstr(ls(Source_Data)));
Files(~contains(Files, '.set')) = [];
Files(~contains(Files, Condition)) = [];
Files(~contains(Files, Task)) = [];

for Indx_F = 1:numel(Files)
    File = Files{Indx_F};
    Core = extractBefore(File, '_Clean');
    Session = extractAfter(Core, [Task,'_']);
    Session = replace(Session, 'Session2Beam1', 'Session2Beam');
    
    Participant = extractBefore(Core, ['_',Task]);
    
    Filename_Microsleeps =  [Core, '_Microsleeps_Cleaned.mat'];
    
    % load EEG
    EEG = pop_loadset('filename', File, 'filepath', Source_Data);
    
    %%% get microsleep windows
    Windows = LoadWindows(fullfile(Source_Microsleeps, Filename_Microsleeps));
    
    EventTypes = {EEG.event.type};
    EventTimes = [EEG.event.latency]/EEG.srate;
    
    StimIndx = find(strcmp(EventTypes, EEG_Triggers.Stim));
    
    Resp = strcmp(EventTypes(StimIndx+1), EEG_Triggers.Response);
    RespTimes = EventTimes(StimIndx+1);
    
    StimTimes = EventTimes(StimIndx);
    MicroStimIndx = any(StimTimes > Windows(:, 1) & StimTimes < Windows(:, 2), 1);
    
    TotStim = numel(StimIndx);
    TotResp = nnz(Resp);
    MicroStim = nnz(MicroStimIndx);
    MicroResp = nnz(MicroStimIndx & Resp);
    

    MicroRT = nanmean(RespTimes(MicroStimIndx(Resp)) - StimTimes(MicroStimIndx(Resp)));
    restRT =  nanmean(RespTimes(~MicroStimIndx(Resp)) - StimTimes(~MicroStimIndx(Resp)));
    
    Tot(strcmp(Participants, Participant), strcmp(Sessions, Session), :) = [TotStim, TotResp];  
   Micro(strcmp(Participants, Participant), strcmp(Sessions, Session), :) = [MicroStim, MicroResp];  
   RTs(strcmp(Participants, Participant), strcmp(Sessions, Session), :) = [restRT, MicroRT];
end

RestHits = 100*((Tot(:, :, 2)-Micro(:, :, 2))./(Tot(:, :, 1)-Micro(:, :, 1)));
Micro(find(Micro(:, :, 1)<5)) = nan;
MicroHits = 100*(Micro(:, :, 2)./Micro(:, :, 1));
figure
PlotScales(RestHits, MicroHits, Sessions, {'RestHits', 'MicroHits'})

figure
PlotScales(RTs(:, :, 1), RTs(:, :, 2), Sessions, {'RestRTs', 'MicroRTs'})


function Windows = LoadWindows(Source)
load(Source, 'Windows')
end
