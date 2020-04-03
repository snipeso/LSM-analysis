clear
clc
close all

Q_Parameters

Figure_Path = fullfile(Figure_Path, 'BAT');

filenames = {'LAT_All.csv', 'PVT_All.csv', 'Music_All.csv', 'Game_All.csv', ...
    'Match2Sample_All.csv', 'SpFT_All.csv'};



for Indx_T = 1:numel(filenames)
    
    if contains(filenames{Indx_T}, 'LAT' )
        Sessions = allSessions.LATBeam;
        SessionLabels = allSessionLabels.LATBeam;
    elseif contains(filenames{Indx_T}, 'PVT' )
        Sessions = allSessions.PVTBeam;
        SessionLabels = allSessionLabels.PVTBeam;
    else
        Sessions = allSessions.Basic;
        SessionLabels = allSessionLabels.Basic;
    end
    
    
    Answers = readtable(fullfile(CSV_Path, filenames{Indx_T}));
    
    
    % Fix qID problem
    Answers.qID(strcmp(Answers.qLabels, 'Frustrating/Neutral/Relaxing')) = {'BAT_2'};
    
    
    qIDs = {'BAT_1', 'BAT_2', 'BAT_3', 'BAT_3_1', 'BAT_4', 'BAT_4_1', 'BAT_5', 'BAT_8'};
    Titles = {'KSS';
        'Frustrating-Relaxing';
        'Boring-Interesting';
        'Distracted-Focused';
        'Easy-Difficult';
        'No Effort-Effortful';
        'Poor-Good Perform';
        'No Motiv-Lots Motiv'};
    
    
    
    Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07'};
    
    
    Colors = [linspace(0, (numel(Participants) -1)/numel(Participants), numel(Participants))', ...
        ones(numel(Participants), 1)*0.2, ...
        ones(numel(Participants), 1)];
    Colors = hsv2rgb(Colors);
    
    figure('Name', filenames{Indx_T}, 'units','normalized','outerposition',[0 0 .5 .7])
    for Indx_Q = 1:numel(qIDs)
        subplot(2, 4, Indx_Q)
        hold on
        AnsAll = nan(numel(Participants), numel(Sessions));
        for Indx_P = 1:numel(Participants)
            for Indx_S = 1:numel(Sessions)
                Ans = Answers.numAnswer(strcmp(Answers.qID, qIDs{Indx_Q}) & strcmp(Answers.dataset, Participants{Indx_P}) & strcmp(Answers.Level2, Sessions{Indx_S}));
                if numel(Ans) < 1
                    continue
                end
                AnsAll(Indx_P, Indx_S) = 100*Ans;
            end
        end
        
        
        for Indx_P = 1:numel(Participants)
            plot(AnsAll(Indx_P, :), 'o-', 'LineWidth', 1, 'MarkerFaceColor', Colors(Indx_P, :), 'Color', Colors(Indx_P, :))
        end
        
        plot(nanmean(AnsAll, 1), 'o-', 'LineWidth', 2, 'Color', 'k',  'MarkerFaceColor', 'k')
        xlim([0, numel(Sessions) + 1])
        xticks(1:numel(Sessions))
        xticklabels(SessionLabels)
        ylim([0 100])
        title(Titles{Indx_Q})
    end
    FigureName =  [extractBefore(filenames{Indx_T}, '_'),  '_BAT.svg'];
    saveas(gcf,fullfile(Figure_Path, FigureName))
end





% TODO: stacked bar on falling asleep