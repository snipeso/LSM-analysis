close all
clear
clc
run(fullfile(extractBefore(mfilename('fullpath'), 'eeg'), 'General_Parameters'))

Filename = 'P09_Sleep_Baseline_Scoring.set';

Filepath = 'C:\Users\colas\Desktop\Temp';


EEG = pop_loadset('filename', Filename, 'filepath', Filepath);
Threshold = .9;
Color = [1 1 0];


% Weights = EEG.icaweights*EEG.icasphere;
% ICAEEG = Weights * EEG.data;

% PlotComponent(EEG, 2)

%%
shortEEG = pop_select(EEG, 'time', [9980 10100]);
 pop_eegplot(shortEEG)
IC = shortEEG.data(63, :);

PrototypeTime = round([5, 11]*EEG.srate); % indicate time window

% PrototypeTime = round([1, 2.2]*EEG.srate); % indicate time window
Prototype = IC(PrototypeTime(1):PrototypeTime(2));


G = gausswin(numel(Prototype));

Sniplet = G'.*Prototype;

figure
hold on
t = linspace(0, numel(Sniplet)/EEG.srate, numel(Sniplet));
plot(t,Sniplet)
plot(t, Prototype);

result = conv(IC, Sniplet, 'same');

R = mat2gray(abs(hilbert(result)));

t = linspace(0, numel(IC)/EEG.srate, numel(IC));
figure
hold on
plot(t, mat2gray(IC))
plot(t, R)
plot(t, mat2gray(abs(result)))
% plot(t, normresult)

%%
Threshold = .2;

% plot sniplets in whole recording
[Starts, Ends] = data2windows(R, Threshold);
newWindows = [Starts(:), Ends(:)];
NewTMPREJ = zeros(size(newWindows, 1), EEG.nbchan + 5);
NewTMPREJ(:, 1:2) = newWindows;
NewTMPREJ(:, 3:5) = repmat(Color,  size(newWindows, 1), 1);



Pix = get(0,'screensize');
 eegplot(EEG.data, 'srate', EEG.srate, 'spacing', 20, 'winlength', 20, ...
 'butlabel', 'Save',    'winrej', NewTMPREJ, 'position', [0 0 Pix(3) Pix(4)])



