clear
clc
close all

%TODO: something is wrong with the kss plot, maybe to do with "bat 6"

Q_Parameters

Figure_Path = fullfile(Paths.Figures, 'BAT');

filenames = {'LAT_All.csv', 'PVT_All.csv', 'Music_All.csv', 'Game_All.csv', ...
    'Match2Sample_All.csv', 'SpFT_All.csv'};

qIDs = {'BAT_1', 'BAT_3_0', 'BAT_3', 'BAT_3_1', 'BAT_4', 'BAT_4_1', 'BAT_5', 'BAT_8'};
Titles = {'KSS';
    'Frustrating-Relaxing';
    'Boring-Interesting';
    'Distracted-Focused';
    'Easy-Difficult';
    'No Effort-Effortful';
    'Poor-Good Perform';
    'No Motiv-Lots Motiv'};

for Indx_T = 1:numel(filenames)
    
    % use appropriate session names
    if contains(filenames{Indx_T}, 'LAT' )|| contains(filenames{Indx_T}, 'PVT' )
        Sessions = allSessions.Comp;
        SessionLabels = allSessionLabels.Comp;
    else
        Sessions = allSessions.Basic;
        SessionLabels = allSessionLabels.Basic;
    end
    
    
    Answers = readtable(fullfile(Paths.CSV, filenames{Indx_T}));
    
    
    % Fix qID problem
    Answers.qID(strcmp(Answers.qLabels, 'Frustrating/Neutral/Relaxing')) = {'BAT_3_0'};

    Task = extractBefore(filenames{Indx_T}, '_');
    
    for Indx_Q = 1:numel(qIDs)

        qID = qIDs{Indx_Q};
         
        % this was named differently just for P01
        if strcmp(qID, 'BAT_1') && nnz(strcmp(Answers.qID, 'BAT_6'))
            qID = 'BAT_6';
        end
        
        [AnsAll, Labels] = TabulateAnswers(Answers, Sessions, Participants, qID, 'numAnswer');
        AnsAll = 100*AnsAll;
        
        if Indx_T == 1
            figure('Name', Titles{Indx_Q}, 'units','normalized','outerposition',[0 0 1 1]);
        else
            figure(Indx_Q)
        end
        
        subplot(2, 3, Indx_T)
        PlotConfettiSpaghetti(AnsAll, Sessions, SessionLabels, [0 100], Task, strsplit(num2str(0:20:100)))
        
        if Indx_T == numel(filenames)
            FigureName =  [Titles{Indx_Q},  '_BAT.svg'];
            saveas(gcf,fullfile(Figure_Path, FigureName))
        end
    end
    
end


% TODO: stacked bar on falling asleep