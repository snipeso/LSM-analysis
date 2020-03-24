










EEG = pop_loadset('filename', 'P03_LAT_Extras_ICAd.set', 'filepath', 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG\Deblinked\LAT')



A = EEG.data(10, :);
for Indx = 1:size(TMPREJ, 1)
    A(round(TMPREJ(Indx, 1)):round(TMPREJ(Indx, 2))) = 0;
end






[pxxWhole, freqs] = pwelch(EEG.data(10, :), fs*4, [], 1:30, fs);
[pxxChopped, freqs] = pwelch(A, fs*4, [], 1:30, fs);


figure
hold on
plot(freqs, pxxWhole)
plot(freqs, pxxChopped)

t = linspace(0, 1, 1000);
x = sin(20*2*pi*t);

xchop = x;
range = 630:835;
xchop(range) = 0;
xsquish = x;
xsquish(range) = [];

% [pxx, freqs] = pwelch(x, length(x), [], 1:30, 1000);
[pxx, freqs] = pwelch(x, round(length(x)/6), [], [], 1000);
[pxchop, freqs] = pwelch(xchop, round(length(x)/6), [], [], 1000);
[pxsquish, freqs] = pwelch(xsquish, round(length(x)/6), [], [], 1000);

figure
subplot(1, 2, 1)
hold on
plot(t, x)
plot(t, xchop)

subplot(1,2,2)
hold on
plot(freqs, pxx)
plot(freqs, pxchop)
plot(freqs, pxsquish)
xlim([0, 30])



% % s =  3./(2*pi*frex);
% % % s = 10./(2*pi*frex);
% % 
% EEG =  pop_loadset('filename', 'P03_MWT_Main.set', 'filepath', 'C:\Users\colas\Desktop\FakeDataPreprocessedEEG\LightFiltering\MWT');
% 
% % EEG = pop_select(EEG, 'time', [577, 583]);
% % % definitions, selections...
% % chan2use = 'fcz';
% 
% min_freq =  1;
% max_freq = 30;
% num_frex = 30;
% 
% % define wavelet parameters
% time = -1:1/EEG.srate:1;
% frex = logspace(log10(min_freq),log10(max_freq),num_frex);
% s    = logspace(log10(3),log10(10),num_frex)./(2*pi*frex);
% % s    =  3./(2*pi*frex); % this line is for figure 13.14
% % s    = 10./(2*pi*frex); % this line is for figure 13.14
% 
% % definte convolution parameters
% n_wavelet            = length(time);
% n_data               = EEG.pnts*EEG.trials;
% n_convolution        = n_wavelet+n_data-1;
% n_conv_pow2          = pow2(nextpow2(n_convolution));
% half_of_wavelet_size = (n_wavelet-1)/2;
% 
% % get FFT of data
% eegfft = fft(mean(EEG.data, 1),n_conv_pow2);
% 
% % initialize
% eegpower = zeros(num_frex,EEG.pnts); % frequencies X time X trials
% 
% baseidx = dsearchn(EEG.times',[1 100]');
% 
% % loop through frequencies and compute synchronization
% for fi=1:num_frex
%     
%     wavelet = fft( sqrt(1/(s(fi)*sqrt(pi))) * exp(2*1i*pi*frex(fi).*time) .* exp(-time.^2./(2*(s(fi)^2))) , n_conv_pow2 );
%     
%     % convolution
%     eegconv = ifft(wavelet.*eegfft);
%     eegconv = eegconv(1:n_convolution);
%     eegconv = eegconv(half_of_wavelet_size+1:end-half_of_wavelet_size);
%     
%     % Average power over trials (this code performs baseline transform,
%     % which you will learn about in chapter 18)
%     temppower = mean(abs(reshape(eegconv,EEG.pnts,EEG.trials)).^2,2);
% %     eegpower(fi,:) = 10*log10(temppower);
%     eegpower(fi,:) = 10*log10(temppower./mean(temppower(baseidx(1):baseidx(2)))); % baseline corected
% end
% 
% figure
% contourf(EEG.times,frex,eegpower,400,'linecolor','none')
% set(gca,'yscale','log','ytick',logspace(log10(min_freq),log10(max_freq),6),'yticklabel',round(logspace(log10(min_freq),log10(max_freq),6)*10)/10)
% title('Logarithmic frequency scaling')
