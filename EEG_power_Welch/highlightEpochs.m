function highlightEpochs(EEG, Window, showEpochs)
Color =[1 1 0];
fs = EEG.srate;
Points = size(EEG.data,2);
    Epochs = Points/(fs*Window);
    Starts = floor(linspace(1, Points - fs*Window, Epochs));
    Ends = floor(Starts + fs*Window);
    Edges = [Starts(:), Ends(:)];
    
    Edges(~showEpochs,:) =[];
    
    
NewTMPREJ = zeros(size(Edges, 1), 133);
NewTMPREJ(:, 1:2) = Edges;
NewTMPREJ(:, 3:5) = repmat(Color,  size(Edges, 1), 1);
    
     eegplot(EEG.data, 'srate', EEG.srate, 'winlength', 30, ...
        'command', 'tmprej = TMPREJ', 'winrej', NewTMPREJ)