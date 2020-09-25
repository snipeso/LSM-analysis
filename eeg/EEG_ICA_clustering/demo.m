% clear
clc
% close all
Subp = 2;
Blinks = [.1 0 10:-1:1, 0, 0];
Eyes = [0 .3 1 4 6 7:-1:1, 0 0];
Muscle = [0 0 1:10, 0 0];
Beta = [0 0 ones(1, 10), .9, 0];
Theta = Beta;
Theta(6) = 2;
Theta(10) = Theta(10) +.1; 
ThetaBoost = Theta;
ThetaBoost(6) = 4;
ThetaBoost(end) = .11;
Alpha = Beta;
Alpha(7) = 2;
Alpha(end-1) = .2;
Alpha2 = zeros(1, numel(Alpha));
Alpha2(7) = 3;
Alpha2(1) = .3;

% from Barua paper
Distance = 'correlation'; 
Link = 'complete';
Normalize = '';

% % instinct:
% Distance = 'mahalanobis'; 
% Link = 'average';
% Normalize = '';

% 
% All = [Blinks; Eyes; Muscle; Beta; Theta; ThetaBoost; Alpha; Alpha2];
% Labels = {'Blinks', 'Eyes', 'Muscle', 'Beta', 'Theta', 'Theta2', 'Alpha', 'Alpha2'};

load('testICAfreq1.mat');
All = compeegspecdB(3:30, 1:40);
load('testICAfreq2.mat');
All = [All; compeegspecdB(3:30, 1:40)];
Labels = [strcat(string(3:30), 'a'), strcat(string(3:30), 'b')];

switch Normalize
    case 'zscore'
    
    All = zscore(All')';
    case 'gray'
        for Indx = 1:size(All, 1)
        All(Indx, :) = mat2gray(All(Indx, :));
        end
end

figure('units','normalized','outerposition',[0 0 1 .5])
subplot(1, Subp, 1)
plot(All')
legend(Labels)

if strcmp(Distance, 'mahalanobis')
     C = cov(All,'omitrows');
     D = pdist(C, Distance);
else
    D = pdist(All, Distance);
end


Z = squareform(D);
disp(Z)
subplot(1, Subp, 2)
imagesc(Z)
xticks(1:numel(Labels))
xticklabels(Labels)
yticks(1:numel(Labels))
yticklabels(Labels)
colorbar

Z = linkage(D,  Link);
% subplot(1, Subp, 3)
figure
dendrogram(Z, 0,'Labels', Labels)

c = cophenet(Z,D);

title(['Cophenet value is: ', num2str(c)])

