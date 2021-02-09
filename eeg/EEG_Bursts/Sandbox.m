% eeglab
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))

EEG = pop_loadset('P10_Game_Session2_Clean.set');
    BL = pop_loadset('P10_Fixation_BaselinePost_Clean.set');
    
    EEG_2 = pop_loadset('P03_Game_Session2_Clean.set');
    BL_2 = pop_loadset('P03_Fixation_BaselinePost_Clean.set');
   
% pop_eegplot(EEG)
% 
% pop_eegplot(EEG, 0)
% 
%   pop_selectcomps(EEG, 1:35);
%   
  
  Comps = EEG;
 Comps.data = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
  Comps.nbchan = size(Comps.data, 1);
 
%   % filter
%   Comps_f = pop_eegfilt(Comps, 4, []);
%     Comps_f = pop_eegfilt(Comps_f, [], 15);
%     
%     Hilby = hilbert(Comps_f.data')';
%     HilbertPower = abs(Hilby);
Bands = struct();
Bands.all = [4 15];
Bands.ref = [.5 5];
[HilbertPower] = HilbertBands(Comps, Bands, 'struct', false);
    
    eegplot(Comps.data, 'srate', EEG.srate, 'eloc_file', 0, 'data2', HilbertPower.all)
    
    
    
      Comps_2 = BL;
 Comps_2.data = eeg_getdatact(BL, 'component', [1:size(BL.icaweights,1)]);
  Comps_2.nbchan = size(Comps_2.data, 1);
    [HilbertPower_2] = HilbertBands(Comps_2, Bands, 'struct', false);
    
    eegplot(Comps_2.data, 'srate', EEG.srate, 'eloc_file', 0, 'data2', HilbertPower_2.all)
    
    
    %%% look at spectrum
    

    

        [pxx, f] = pwelch(EEG.data(11, :), EEG.srate*5, 0, [1:0.5:50], EEG.srate,  'power');
    
    
        [pxx, f] = pwelch(EEG.data(11, :), EEG.srate*5, 0, [1:0.5:50], EEG.srate);
    [pxxbl, f] = pwelch(BL.data(11, :),  EEG.srate*5, 0, [1:0.5:50], EEG.srate);
    
        
        [pxx_2, f] = pwelch(EEG_2.data(11, :), EEG.srate*5, 0, [1:0.5:50], EEG.srate);
    [pxxbl_2, f] = pwelch(BL_2.data(11, :),  EEG.srate*5, 0, [1:0.5:50], EEG.srate);
    
    figure
    plot(f, pxx)
    hold on
    plot(f, pxxbl)
        plot(f, pxx_2)
        plot(f, pxxbl_2)
        legend({'P10 SD', 'P10 BL', 'P3 SD', 'P3 BL'})
        
        
        
        %%% get actual amplitudes:
        
        
        % burst classification:
        
        D = HilbertPower_2.all(1,:);
pd = fitdist(D','kernel');
y = pdf(pd, x);
figure; subplot(1, 2, 1);histogram(D);xlim([0 10]); subplot(1,2,2); plot(x, y)
[~,Lim_Indx] = max(y); Lim = x(Lim_Indx);
figure;plot(t_bl, D); hold on; plot(t_bl([1, end]), [Lim, Lim].*3)

% anything over> 3*Lim can qualify, but it has to last at least 3 cycles;
% so >.4s

MinAmp = 2;
MinP = 0.25*EEG.srate;
x = 0:.1:10;
Data = HilbertPower.all(2, :);
Data = smooth(Data, 1*EEG.srate)';
Windows = BurstDetection(Data, MinAmp, MinP, x);

t = linspace(0, numel(Data)/EEG.srate, numel(Data));
figure
plot(t, Comps.data(2, :))
hold on

Bursts = windows2data( Comps.data(2, :), Windows);
plot(t, Bursts);

plot(t, Data)
        
        
        
        