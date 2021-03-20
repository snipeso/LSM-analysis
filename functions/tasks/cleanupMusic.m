function Answers = cleanupMusic(AllAnswers)
% take table from AllAnswers, save relevant information



Answers = AllAnswers(:, {'Participant', 'Session', 'song'});

% remove from cell structure
Answers.Participant = string(Answers.Participant);
Answers.Session = string(Answers.Session);
Answers.song =  string(Answers.song);

