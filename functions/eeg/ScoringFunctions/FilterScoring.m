function EEG = FilterScoring(EEG)
% takes an EEGLAB structure, and filters the EEG and EMG data separately.

%%% General filter parameters
fs = EEG.srate;
fs_new = 128;
passRipple = 0.02;
stopAtten = 60;


%%% EEG filter parameters

% % FIR filter 0.5 Hz - equiripple
% hp_Frq_EEG = 0.5;
% hp_stopFrq_EEG = 0.2;
% hp_stopAtten_EEG = 60; %-subtract mean, stp 60

% % % FIR filter 0.5 Hz - equiripple
hp_Frq_EEG = 0.8;
hp_stopFrq_EEG = 0.51;
hp_stopAtten_EEG = 60;


% FIR filter 35 Hz - equiripple
lp_Frq_EEG = 29.75;
lp_stopFrq_EEG = 49.7; % Reduces 50Hz nicely


%%% EMG filters

% FIR filter 10 Hz - equiripple
hp_Frq_EMG = 13;
hp_stopFrq_EMG = 9.25;

% FIR filter 100 Hz - equiripple
lp_Frq_EMG = 92.5;
lp_stopFrq_EMG = 107.5;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Process the data

% subtract the mean
EEG.data = EEG.data-mean(EEG.data, 2); % TODO: check if it works

% 50Hz notch filter to all
wo = 50/(fs/2);  bw = wo/15;
[num, den] = iirnotch(wo,bw);
EEG.data = filtfilt(num, den, double(EEG.data)')';

% low pass filter EEG
lpFilt = designfilt('lowpassfir', ...
    'PassbandFrequency', lp_Frq_EEG, ...
    'StopbandFrequency', lp_stopFrq_EEG, ...
    'StopbandAttenuation', stopAtten, ...
    'PassbandRipple', passRipple,...
    'SampleRate', fs, ...
    'DesignMethod', 'equiripple');
EEG = firfilt(EEG, lpFilt.Coefficients, [], 1:12);

% EEG.data = eegfilt(EEG.data, fs_new, 0, 40);

% low pass filter EMG
lpFilt = designfilt('lowpassfir', ...
    'PassbandFrequency', lp_Frq_EMG, ...
    'StopbandFrequency', lp_stopFrq_EMG, ...
    'StopbandAttenuation', stopAtten, ...
    'PassbandRipple', passRipple,...
    'SampleRate', fs, ...
    'DesignMethod', 'equiripple');
EEG = firfilt(EEG, lpFilt.Coefficients, [], 13:14);

% resample
EEG = pop_resample(EEG, fs_new);

% high pass filter EEG (this is slower, so done after resampling)
hpFilt = designfilt('highpassfir', ...
    'PassbandFrequency', hp_Frq_EEG, ...
    'StopbandFrequency', hp_stopFrq_EEG, ...
    'StopbandAttenuation', hp_stopAtten_EEG, ...
    'PassbandRipple', passRipple,...
    'SampleRate', fs_new, ...
    'DesignMethod', 'equiripple');
EEG = firfilt(EEG, hpFilt.Coefficients, [], 1:12);

% EEG.data = eegfilt(EEG.data, fs_new, .5, 0);

% high pass filter EMG
hpFilt = designfilt('highpassfir', ...
    'PassbandFrequency', hp_Frq_EMG, ...
    'StopbandFrequency', hp_stopFrq_EMG, ...
    'StopbandAttenuation', stopAtten, ...
    'PassbandRipple', passRipple,...
    'SampleRate', fs_new, ...
    'DesignMethod', 'equiripple');
EEG = firfilt(EEG, hpFilt.Coefficients, [], 13:14);
