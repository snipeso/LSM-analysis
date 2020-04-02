clear
clc
close all

% 
% Sessions = {'BaselineBeam', 'Session1Beam', 'Session2Beam1',};
% SessionLabels = {'BLb', 'S1b', 'S2b1',};
Sessions = {'BaselineComp', 'BaselineBeam', 'Session2Comp', 'Session2Beam1'};
SessionLabels = {'BLc', 'BLb', 'S2c', 'S2b1'};

% Sessions = {'BaselineComp', 'Session1Comp', 'Session2Comp',};
% SessionLabels = {'BLc', 'S1c', 'S2c',};

% Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'Session2Beam2', 'Session2Beam3', 'MainPost'};
% SessionLabels = {'BL', 'Pre', 'S1', 'S2-1', 'S2-2', 'S2-3', 'Post'};


filename = 'LAT_All.csv';

Answers = readtable(filename);

qIDs = {'BAT_1', 'BAT_3_1', 'BAT_4', 'BAT_4_1', 'BAT_5', 'BAT_8'};
Titles = {'KSS';
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

figure
for Indx_Q = 1:numel(qIDs)
    subplot(2, 3, Indx_Q)
    hold on
    AnsAll = nan(numel(Participants), numel(Sessions));
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions)
            Ans = Answers.numAnswer(strcmp(Answers.qID, qIDs{Indx_Q}) & ...
                strcmp(Answers.dataset, Participants{Indx_P}) & ...
                strcmp(Answers.Level2, Sessions{Indx_S}));
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







% TODO: stacked bar on falling asleep