% score LAT
close all
clc
clear
TooSoon = 0.1;

 filepath = 'C:\Users\colas\Projects\LSM-analysis\taskPerformance\LAT\';
 filename = 'Spre.log';
 
filepath = [filepath, filename];
LAT = importOutput(filepath, 'struct');


% plot distribution of RTs in space
coordinates = [LAT.coordinates];
X = coordinates(1, :);
Y = coordinates(2, :);
RT = [LAT.rt];
RT(isnan(RT)) = 1;
RT(RT<=TooSoon) = nan;

plotSpots(X, Y, RT); %NOTE: good for individual runs
PlotHeatRT(X, Y, RT); %NOTE: good for group


% answers distribution
figure
RT_disp = RT;
RT_disp(isnan(RT)) = 1.5;
histogram(RT_disp, 20)
xlim([0, 1.6])