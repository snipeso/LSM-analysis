function Output = importOutput(filepath, OutputType)

TrialStruct = struct();

% convert from txt to cell array
Text = fileread(filepath);
TextTrials = splitlines(Text);

% convert JSON in each cell to struct
for Indx_T = 1:numel(TextTrials)
    
    % skip empty rows
    if isempty(TextTrials{Indx_T})
        continue
    end
    
    % convert from JSON to struct
    Struct = jsondecode(TextTrials{Indx_T});
    
    % add new possible field names to ongoing trials structure
    FNS = fieldnames(Struct);
    FNTS = fieldnames(TrialStruct);
    NewFields = setdiff(FNS, FNTS);
    for Field = NewFields'
        TrialStruct(Indx_T).(Field{1}) = Struct.(Field{1});
    end
    
    % add pre-existing fieldnames to current structure, blank
    OldFields = setdiff(FNTS, FNS);
    for Field = OldFields'
        Struct.(Field{1}) = nan;
    end
    
    % add current structure to ongoing trials structure
    TrialStruct(Indx_T)  = Struct;
end

% change output based on what was specified
switch OutputType
    case 'table'
        Output = struct2table(TrialStruct);
    otherwise
        Output = TrialStruct;
end

