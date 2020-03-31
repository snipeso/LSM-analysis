LAT_Parameters
[Subfolders, Datasets] = AllFolderPaths(Paths.Datasets, 'PXX', false, {'CSVs', 'Lazy', 'P00'});

Task = 'LAT';
% SaveFields = {'Participant', 'Task', 'Session', 'Filename', 'block', ...
%     'coordinates',  'hemifield', 'rt',  'late', 'missed',  ...
%     'startTime', 'delay', 'tones', 'trialID'};

Subfolders(~contains(Subfolders, Task)) = [];
Subfolders(~contains(Subfolders, 'Behavior')) = [];
AllAnswers = table();
for Indx_P = 1:numel(Datasets)
    for Indx_S = 1:numel(Subfolders)
        Participant = deblank(Datasets(Indx_P, :));
        Folder = fullfile(Paths.Datasets, Participant, Subfolders{Indx_S});
        Files = cellstr(ls(Folder));
        
        Files(~contains(Files, '.log')) = [];
        Files(contains(Files, 'configuration')) = [];
        
        if numel(Files) < 1
            warning([Folder, ' is empty'])
            continue
        elseif numel(Files)>1
            warning([Folder, ' has too many files'])
            continue
        end
        
        Session = extractBetween(Subfolders{Indx_S}, [Task, '\'], '\Behavior');
        extraFields = {'Participant', 'Task', 'Session', 'Filename';
            Participant, Task, Session{1}, Files{1}};
        
       Output = importOutput(fullfile(Folder, Files{1}), 'table', extraFields);
       
       % deal with stupid exceptions
       OutputColNames = Output.Properties.VariableNames;
       CurrentColNames = AllAnswers.Properties.VariableNames;
       for Indx_C = 1:numel(OutputColNames)
           ColName = OutputColNames{Indx_C};
           Col = Output.(ColName);
          if ~iscell(Col)
              Output.(ColName) = num2cell(Col);
          end
          
          % add new column to mega table if it doesn't already have it
          if ~any(ismember(CurrentColNames, OutputColNames{Indx_C}))
              AllAnswers.(ColName) = cell([size(AllAnswers, 1), 1]);
          end
       end
       

       % if 
       
        AllAnswers = [AllAnswers; Output];
    end
    
end