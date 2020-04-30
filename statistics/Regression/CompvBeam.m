clear
clc
close all

Regression_Parameters

Correction = 'norm'; % 'change', 'zscore' 'none'

Files = {
    'LAT_Theta_log';
    'LAT_meanRTs';
    'LAT_Hits';
    'LAT_Misses';
    'LAT_KSS';
    'LAT_TimeAwake'
    };

figure('units','normalized','outerposition',[0 0 1 .5])
p=panel();
p.pack(2, numel(Files))
for Indx_E = 1:2
    switch Indx_E
        case 1
            Task ='LATBeam';
            Sessions = allSessions.LAT;
            SessionLabels = allSessionLabels.LAT;
            
            subSessions = allSessions.Beam;
            subSessionLabels = allSessionLabels.Beam;
            Ending = '_Beam.mat';
            
            
        case 2
            Task = 'LATComp';
            
            Sessions = allSessions.Comp;
            SessionLabels = allSessionLabels.Comp;
            subSessions = allSessions.Comp;
            subSessionLabels = allSessionLabels.Comp;
            Ending = '_Comp.mat';
            
    end
    Labels = extractAfter(Files, 'LAT_');
    DataPath = fullfile(Paths.Data, Task);
    
    Task = [Task, ' ', Correction];
    
    
    Matrix2 = nan(numel(Participants)*numel(subSessions), numel(Files)); % temp
    
    
    
    for Indx_F = 1:numel(Files)
        load(fullfile(DataPath, [Files{Indx_F}, Ending]), 'Matrix')
        
        Matrix = Matrix(:, contains(Sessions, subSessions));
        
%         Matrix = zscore(Matrix, 0, 2);
        
        Matrix2(:, Indx_F) = reshape(Matrix, [], 1);
        
        if Indx_F == numel(Files)
            continue
        end
        
        %         subplot(2, numel(Files), (Indx_E-1)*numel(Files) + Indx_F)
        p(Indx_E, Indx_F).select()
        PlotConfettiSpaghetti(mat2gray(Matrix), subSessions, subSessionLabels, [-0.1 1.1],[Task, ' ', Labels{Indx_F}], [])
        
    end
    
    
    [R,P] = corrcoef(Matrix2, 'Rows','pairwise');
    Labels = replace(Labels, '_', ' ');
    
%     subplot(2, numel(Files), Indx_E*numel(Files))
    p(Indx_E, numel(Files)).select()
    [~,h] = fdr(P, 0.05);
    PlotCorr(R, h, Labels)
        PlotCorr(R, [], Labels)
    title([Task, ' R, fdr'])
    
    disp(h)
    
end

saveas(gcf,fullfile(Paths.Figures, [Task, '_CorrAll.svg']))

% normed to Pre




%TODO: eventually convert matrix into a table, and do fancier regression


