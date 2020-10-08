close all


Filename = 'P08_MWT_Main_ICA_Components.set';

Filepath = 'C:\Users\colas\Desktop\Temp';


EEG = pop_loadset('filename', Filename, 'filepath', Filepath);

Weights = EEG.icaweights*EEG.icasphere;
ICAEEG = Weights * EEG.data;

PlotComponent(EEG, 2)
IC = ICAEEG(2, :);

PrototypeTime = round([383, 384.5]*EEG.srate); % indicate time window

% PrototypeTime = round([1, 2.2]*EEG.srate); % indicate time window
Prototype = IC(PrototypeTime(1):PrototypeTime(2));


G = gausswin(numel(Prototype));

Snipet = G'.*Prototype;

figure
hold on
t = linspace(0, numel(Snipet)/EEG.srate, numel(Snipet));
plot(t,Snipet)
plot(t, Prototype);

nIC = 2^nextpow2(numel(IC));
nSni =  2^nextpow2(numel(Snipet));
% R = ifft(fft(IC, nIC) .* fft(Snipet, nSni), nIC);

result = conv(IC, Snipet, 'same');

normresult = mat2gray(abs(result));
R = mat2gray(envelope(abs(result), EEG.srate/10, 'peak'));

t = linspace(0, numel(IC)/EEG.srate, numel(IC));
figure
hold on
plot(t, mat2gray(IC))
plot(t, R)
% plot(t, normresult)


