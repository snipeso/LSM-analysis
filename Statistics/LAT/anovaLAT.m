clear
clc
close all


Stats_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DataPath = fullfile(Paths.Analysis, 'Statistics', 'LAT', 'Data'); % for statistics

% Data type
Type = 'theta';
YLabel = 'VAS Score';
Loggify = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



load(fullfile(DataPath, ['LAT_', Type, '_Classic.mat']))
ClassicMatrix = Matrix;
if Loggify
    ClassicMatrix = log(ClassicMatrix);
end

ClassicMeans = nanmean(ClassicMatrix);
ClassicSEM = nanstd(ClassicMatrix)./sqrt(size(ClassicMatrix, 1));
Classic = mat2table(ClassicMatrix, Participants, {'s1', 's2', 's3'}, 'Participant', [], Type);


load(fullfile(DataPath, ['LAT_', Type, '_Soporific.mat']))
SopoMatrix = Matrix;
if Loggify
    SopoMatrix = log(SopoMatrix);
end

SopMeans = nanmean(SopoMatrix);
SopSEM = std(SopoMatrix)./sqrt(size(SopoMatrix, 1));

Soporific = mat2table(SopoMatrix, Participants, {'s4', 's5', 's6'}, 'Participant', [], Type);


Between = [Classic, Soporific(:, 2:end)];

Within = table();
Within.Session = {'B'; 'S1'; 'S2'; 'B'; 'S1'; 'S2'};
Within.Condition = {'C'; 'C'; 'C'; 'S'; 'S'; 'S'};

rm = fitrm(Between,'s1-s6~1', 'WithinDesign',Within);

ranovatbl = ranova(rm, 'WithinModel', 'Session*Condition');
SxC = multcompare(rm, 'Session', 'By', 'Condition');
CxS = multcompare(rm, 'Condition', 'By', 'Session');

%%% manually assemble p-values

% within session comparisons
BL_SvC = CxS.pValue(strcmp(CxS.Session, 'B')&strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
S1_SvC = CxS.pValue(strcmp(CxS.Session, 'S1')&strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));
S2_SvC = CxS.pValue(strcmp(CxS.Session, 'S2')&strcmp(CxS.Condition_1, 'S')& strcmp(CxS.Condition_2, 'C'));

% between session comparisons
S_BLvS1 = SxC.pValue(strcmp(SxC.Condition, 'S')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S1'));
S_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'S')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S2'));
S_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'S')&strcmp(SxC.Session_1, 'S1')& strcmp(SxC.Session_2, 'S2'));
C_BLvS1= SxC.pValue(strcmp(SxC.Condition, 'C')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S1'));
C_BLvS2= SxC.pValue(strcmp(SxC.Condition, 'C')&strcmp(SxC.Session_1, 'B')& strcmp(SxC.Session_2, 'S2'));
C_S1vS2= SxC.pValue(strcmp(SxC.Condition, 'C')&strcmp(SxC.Session_1, 'S1')& strcmp(SxC.Session_2, 'S2'));

% plot barplots
figure
PlotBars([ClassicMeans; SopMeans]', [ClassicSEM; SopSEM]', {'BL', 'S1', 'S2'}, {'Classic', 'Soporific'})

title(['LAT ', Type])
ylabel(YLabel)

% plot significance 
% (if I'm ever inspired, I'll make this automated; for now its manual)
comparisons = {
[.9, 1.1], BL_SvC;
[1.9, 2.1], S1_SvC;
[2.9, 3.1], S2_SvC;

[.9, 1.9], C_BLvS1;
[1.1, 2.1], S_BLvS1;
[.9, 2.9], C_BLvS2;
[1.1, 3.1], S_BLvS2;
[1.9, 2.9], C_S1vS2;
[2.1, 3.1], S_S1vS2
};

comparisons([comparisons{:, 2}]>=0.1, :) = [];
if size(comparisons, 1) > 0
sigstar(comparisons(:, 1),[comparisons{:, 2}])
end


%%% plot effect sizes (with CIs?) of Session vs Condition


% uses the MES toolbox, so data needs to be restructured
ClassicTable = mat2table(ClassicMatrix, Participants, [1:size(ClassicMatrix, 2)]', ...
    'Participant', 'Session', 'Data');
ClassicTable.Condition = zeros(size(ClassicTable.Session));

SopoTable = mat2table(SopoMatrix, Participants, [1:size(SopoMatrix, 2)]', ...
    'Participant', 'Session', 'Data');
SopoTable.Condition = ones(size(SopoTable.Session));
Table = [ClassicTable; SopoTable];

stats = mes2way(Table.Data, [Table.Session, Table.Condition], 'eta2', ...
    'fName',{'Session', 'Condition'}, 'isDep',[1 1], 'nBoot', 1000)


