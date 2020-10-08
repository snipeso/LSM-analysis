function PlotComponent(EEG, KeepComponents)


badcomps = 1:size(EEG.icaweights, 1);
badcomps(KeepComponents) = [];
NewEEG = pop_subcomp(EEG, badcomps);

Data2 = NewEEG.data;



Range = 1;
Data2(abs(Data2)<Range) = nan;

eegplot(Data2, 'srate', EEG.srate, 'spacing', 10, 'winlength', 10)