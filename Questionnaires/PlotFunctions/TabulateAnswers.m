function [AnsAll, Labels] = TabulateAnswers(Answers, Sessions, Participants, qID, ColName)
% puts answers from table into a matrix that gets used by the plotting
% functions.
% Answers is the table
% Sessions is the list of sessions to plot
% Participants is a cell list of the participant stirng names
% qID is the string of the question in the qID column of tha table
% ColName specifies the column where the answer can be found

% AnsAll is a participant x session matrix of numeric answers
% Labels is a cell list of the corresponding labels of the question

% create empty matrix or cell array, depending on what the datatype is
if isa(Answers.(ColName)(1), 'double') || isa(Answers.(ColName)(1), 'single')
    AnsAll = nan(numel(Participants), numel(Sessions));
else
    AnsAll = cell(numel(Participants), numel(Sessions));
end

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        
        % get answer of specific session for specific participant
        QuestionIndexes = strcmp(Answers.qID, qID) & strcmp(Answers.dataset, Participants{Indx_P}) & strcmp(Answers.Level2, Sessions{Indx_S});
        Ans = Answers.(ColName)( QuestionIndexes);
        
        % handle problems
        if numel(Ans) < 1
            continue
        elseif numel(Ans) > 1
            error(['Not unique answers for ', qID, ' in ' Participants{Indx_P}, ' ', Sessions{Indx_S} ])
        end
        
        % save in appropriate way
        if isa(Ans, 'double') || isa(Ans, 'single')
            AnsAll(Indx_P, Indx_S) = Ans;
        else
            AnsAll(Indx_P, Indx_S) = {Ans};
        end
        
    end
end

%%% gather labels
Labels = Answers.qLabels(find(QuestionIndexes, 1));
Labels = replace(Labels, '//', '-');
Labels = split(Labels, '-');

% hack, because sometimes // splits labels, sometimes just / -.-"
if numel(Labels) == 1
    Labels = split(Labels, '/');
end

% cut short really long labels
for Indx_L = 1:numel(Labels)
    if contains( Labels{Indx_L}, ',')
        Labels{Indx_L} = extractBefore(Labels{Indx_L}, ',');
    end
end
end