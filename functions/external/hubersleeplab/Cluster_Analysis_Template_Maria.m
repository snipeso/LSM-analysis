clear
close all

%% 
cd('/Users/mariadimitriades/Desktop/SWA/Interpolated')
load('SWA_1_4.5_Hz_FH_06-Dec-2020_interpolated.mat')

npower_EOS(13:24,:)=NaN
%note if want n/ipower
%change for samp size (NaN if have more in one group (i.e. 24HC, 12 EOS)

u = 10000
%change the size of this depending on sample size, at some point it will
%stop changing the output. Had 36 partipants (try with 1000 and 10'000)

x1=npower_EOS
x2=npower_Cont
%note if want n/ipower

type = 'uttest'
%here, we marked uttest, as used unpaired ttest to analysize

nch=128
% # of channels

cv= 2.0322
%can figure out the critical value online, from a statistics calculator
%degrees of freedom depends on the type of test; for upaired t-test: N-2
%try here: https://www.omnicalculator.com/statistics/critical-value

path = ('/Users/mariadimitriades/Desktop/Cluster_Analysis_Scripts/CAresults')
CompName = (['SWA_1_4.5_Hz_FH_06-Dec-2020','_clusteranalysis.mat'])

statsresults = SnPM_uttest_corr_clus_def_AM(u,x1,x2,type,nch,cv,path,CompName)

cd('/Users/mariadimitriades/Desktop/Cluster_Analysis_Scripts/CAresults')
save('SnPM_resultsCA_FH_ipower')
%%
%When analyzing...
%clus_min gives us the largest cluster that was found
%clus_max gives us the smallest cluster that exists 
%p95_clus_min to figure out how many you need to be significant
