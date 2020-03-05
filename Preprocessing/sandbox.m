Path = 'C:\Users\colas\Desktop\FakeData\P01\Session1\EEG\';
Filename = 'P03_PVTevening.set';

% Path = 'C:\Users\colas\Desktop';
% Filename = 'littlesleep.set';

EEG = pop_loadset('filename', Filename, 'filepath', Path);
ch = 100;

%%%% Preferred pipeline
A = tic;
EEGi = lineFilter(EEG, 'EU', false);
B=toc(A);
A = tic;
EEGi = pop_resample(EEGi, 256);
B=toc(A);
A = tic;
EEGi = pop_eegfiltnew(EEGi, [], 40);
B=toc(A);
A = tic;
EEGi =  bandpassEEG(EEGi, 0.5, []);
B=toc(A);
A = tic;

%%%%





A = tic;
EEG_filt =  pop_eegfiltnew(EEG, 0.5, 40);
B = toc(A);
A = tic;
EEG_filt_resamp_256 = pop_resample(EEG_filt, 256);
B = toc(A);

EEG_filtsven = bandpassEEG(EEG, 0.5, 40);


A = tic;
EEG_resamp256 = pop_resample(EEG, 256);
B = toc(A);
A = tic;
EEG_resamp256_filt =  pop_eegfiltnew(EEG_resamp256, 0.5, 40);
B = toc(A);


%
A = tic;
EEG_notch  = lineFilter(EEG, 'EU', true);
EEG_notch_resamp256 = pop_resample(EEG_notch, 256);
B = toc(A);
A = tic;
EEG_notch_resamp256_filt =  pop_eegfiltnew(EEG_notch_resamp256, 0.5, 40);
B = toc(A);


EEG_notch_resamp256_filtsven = bandpassEEG(EEG_notch_resamp256, 0.5, 40);
B = toc(A);


x = EEG_filt_resamp_256 .data';
window = 4;
freqs = 1:0.5:100;
fs = 256;
A = tic;
[pxx,f] = pwelch(x,window*fs,[],freqs,fs);
% [pxx,f] = pwelch(x,2^nextpow2(window*fs),[],freqs,fs);
B = toc(A);
plot(f, log(pxx))

save()
% To test:
% FFT speed with 128 vs 120 srate
% resample before and after filtering
% notch filter + filter vs just filter




% ch10notch = EEG_notch.data(ch, :);
% ch10notchds = EEG_notch_resamp256.data(ch, :);
% ch10notchdsfilt = EEG_notch_resamp256_filt.data(ch, :);
ch10raw = EEG.data(ch, :);
% ch10filt = EEG_filt.data(ch, :);
% ch10filtsven = EEG_filtsven.data(ch, :);
% ch10ds250 = EEG_resamp_250.data(ch, :);
% ch10ds256 = EEG_resamp_256.data(ch, :);
% ch10ds256filt = EEG_resamp256_filt.data(ch, :);
% ch10filtds256 = EEG_filt_resamp_256.data(ch, :);
chI = EEGi.data(ch, :);

traw = linspace(0, numel(ch10raw)/1000, numel(ch10raw));
% t250 = linspace(0, numel(ch10ds250)/250, numel(ch10ds250));
t256 = linspace(0, numel(ch10ds256filt)/256, numel(ch10ds256filt));

% 
% figure
% hold on
% plot(traw, ch10raw, 'k', 'LineWidth', 2)
% plot(traw, ch10filt)
% plot(traw, ch10filtsven)
% % plot(t250, ch10ds250)
% % plot(t256, ch10ds256)
% plot(t256, ch10filtds256)
% plot(t256, ch10ds256filt)
% plot(traw, ch10notch, '--')
% plot(t256, ch10notchdsfilt, '--')
% plot(t256, chI, '--', 'LineWidth', 2)
% 
% legend({'raw', 'filt', 'filtsven',  'filtds', 'dsfilt', 'notch', 'notchdsfilt', 'combo'})
% 

x = ch10raw;
fs = 1000;
window = fs*20;
[xraw,f1000] = pwelch(x, window,[],length(x),fs);
% 
% x = ch10notch;
% [xnotch,f] = pwelch(x, window,[],length(x),fs);
% 
% x = ch10filt;
% [xfilt,f] = pwelch(x, window,[],length(x),fs);
% 
% 
% x = ch10filtsven;
% [xfiltsven,f1000] = pwelch(x, window,[],length(x),fs);

% x = ch10ds256filt;
fs = 256;
window = fs*20;
% [xdsfilt,f256] = pwelch(x, window,[],length(x),fs);

x = chI;
[xchI,f256] = pwelch(x, window,[],length(x),fs);


figure
hold on
plot(f1000, log(xraw))
% plot(f1000, log(xnotch))
% plot(f1000, log(xfilt))
% plot(f1000, log(xfiltsven))
% plot(f256, log(xdsfilt))
plot(f256, log(xchI))

legend({'raw', 'notch' 'filt', 'filtsven', 'dsfilt', 'combo'})

