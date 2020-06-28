clear
clc
close all

Regression_Parameters

Task ='LAT';
% Task = 'LATComp';
Correction = 'zscore'; % 'change', 'zscore' 'none'

NormCol = 2;
DataPath = fullfile(Paths.Analysis, 'statistics', 'Data', Task); % for statistics


Sessions = allSessions.LAT;
SessionLabels = allSessionLabels.LAT;

% Sessions = allSessions.Comp;
% SessionLabels = allSessionLabels.Comp;

%%% to automatically get all files
% Files = cellstr(ls(DataPath));
% Files(~contains(Files, '.mat')) = [];

%%% only do desired files
Files = {
    'LAT_Alpha_Classic.mat'
    
    };

Labels = extractBetween(Files, 'LAT_', '_Beam.mat');
%  Labels = extractBetween(Files, 'LAT_', '_Comp.mat');

Task = [Task, Correction];

switch Correction
    case 'change'
        
        Matrix2 = nan(numel(Participants)*(numel(Sessions)-1), numel(Files)); % temp
        
    otherwise
        Matrix2 = nan(numel(Participants)*numel(Sessions), numel(Files)); % temp
        
end


for Indx_F = 1:numel(Files)
    load(fullfile(DataPath, Files{Indx_F}), 'Matrix')
    
    switch Correction
        case 'change'
            Matrix = (Matrix-Matrix(:, NormCol));
            Matrix(:,NormCol) = [];
        case 'zscore'
            Matrix = zscore(Matrix, 0, 2);
            
            for Indx_P = 1:numel(Participants)
                All = zscore([ClassicMatrix(Indx_P, :), SopoMatrix(Indx_P, :)]);
                ClassicMatrix(Indx_P, :) = All(1:size(ClassicMatrix, 2));
                SopoMatrix(Indx_P, :) = All(size(ClassicMatrix, 2)+1:end);
            end
            
    end
    Matrix2(:, Indx_F) = reshape(Matrix, [], 1);
    
end

[R,P] = corrcoef(Matrix2, 'Rows','pairwise');
Labels = replace(Labels, '_', ' ');
figure('units','normalized','outerposition',[0 0 1 1])
PlotCorr(R, [], Labels)
title([Task, ' R values of all parameters'])
saveas(gcf,fullfile(Paths.Figures, [Task, '_CorrAll.svg']))

figure('units','normalized','outerposition',[0 0 1 1])
PlotCorr(R, P, Labels)
title([Task, ' R values of all parameters, 0.05 corrected'])
saveas(gcf,fullfile(Paths.Figures, [Task, '_CorrAllcorrected.svg']))

figure('units','normalized','outerposition',[0 0 1 1])
[~,h] = fdr(P, 0.05);
PlotCorr(R, h, Labels)
title([Task, ' R values of all parameters, fdr corrected'])
saveas(gcf,fullfile(Paths.Figures, [Task, '_CorrAllfdrcorrected.svg']))


% normed to Pre




%TODO: eventually convert matrix into a table, and do fancier regression


