pop_spectopo

pop_eegplot

pop_subcomp



 spectopo
 
 
 spectcomp
 
 spectrum(g.weights*EEG.data)
 
 % contains the topographies of each component
 EEG.icawinv % channels x component
 
 
 % weights:
 A =  EEG.icaweights*EEG.icasphere;
 
 % I think timeline data;
 ICAEEG = A* EEG.data;