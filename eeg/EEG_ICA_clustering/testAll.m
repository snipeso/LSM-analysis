
clear
clc
close all
Subp = 3;
Blinks = [0 0 10:-1:1, 0, 0];
Eyes = [0 0 1 4 6 7:-1:1, 0 0];
Muscle = [0 0 1:10, 0 0];
Beta = [0 0 ones(1, 10), 0, 0];
Theta = Beta;
Theta(6) = 2;
ThetaBoost = Theta;
ThetaBoost(6) = 4;
Alpha = Beta;
Alpha(7) = 2;
Alpha2 = zeros(1, numel(Alpha));
Alpha2(7) = 3;


Distances = {'euclidean',  'correlation', 'hamming', 'jaccard', 'spearman'}; % 'mahalanobis'?
Links = {'average', 'complete', 'single'};
Normalizations = {'', 'zscore', 'gray'};

Labels = {'Blinks', 'Eyes', 'Muscle', 'Beta', 'Theta', 'Theta2', 'Alpha', 'Alpha2'};

for Indx_N = 1:numel(Normalizations)
    
    All = [Blinks; Eyes; Muscle; Beta; Theta; ThetaBoost; Alpha; Alpha2];
    Normalize = Normalizations{Indx_N};
    switch Normalize
        case 'zscore'
            
            All = zscore(All')';
        case 'gray'
            for Indx = 1:size(All, 1)
                All(Indx, :) = mat2gray(All(Indx, :));
            end
    end
    
    for Indx_D = 1:numel(Distances)
        Distance = Distances{Indx_D};

        
        for Indx_L = 1:numel(Links)
            Link = Links{Indx_L};
            
            
            figure('units','normalized','outerposition',[0 0.5 1 .5])
            subplot(1, Subp, 1)
            plot(All')
            legend(Labels)
            title(Normalize)

            if strcmp(Distance, 'mahalanobis')
                
            else
                 D = pdist(All, Distance);
            end
           
            Z = squareform(D);
            subplot(1, Subp, 2)
            imagesc(Z)
            xticks(1:numel(Labels))
            xticklabels(Labels)
            yticks(1:numel(Labels))
            yticklabels(Labels)
            colorbar
            title(Distance)
            
            Z = linkage(D,  Link);
            subplot(1, Subp, 3)
            dendrogram(Z, 'Labels', Labels)
            
            c = cophenet(Z,D);
            
            title([Link, ' cophenet: ', num2str(c)])
            
        end
    end
end
