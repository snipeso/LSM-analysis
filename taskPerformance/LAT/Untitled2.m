
TrialStruct = struct();

Text = fileread(filepath);

TextTrials = splitlines(Text);

for Indx_T = 1:numel(TextTrials)
    if isempty(TextTrials{Indx_T})
        continue
    end
   Struct = jsondecode(TextTrials{Indx_T});
    
   FNS = fieldnames(Struct);
   FNTS = fieldnames(TrialStruct);
   NewFields = setdiff(FNS, FNTS);
    for Field = NewFields'
       TrialStruct(Indx_T).(Field{1}) = Struct.(Field{1});
    end
    
    OldFields = setdiff(FNTS, FNS);
    for Field = OldFields'
       Struct.(Field{1}) = nan; 
    end

    TrialStruct(Indx_T)  = Struct;
end