 EEG.reject.gcompreject = ones(size( EEG.reject.gcompreject));


Weights = EEG.icaweights*EEG.icasphere;
            ICAEEGBL = Weights * EEG.data;
            
            
            BLKeep = ~[EEG.reject.gcompreject];
            
              ICAEEGBL_Clean = ICAEEGBL(BLKeep, :);
              
              WelchWindow = 3;
              Freqs = 2.5:.1:40; 
              
              BLFFTICA =  pwelch( ICAEEGBL_Clean', WelchWindow*EEG.srate, [], Freqs, EEG.srate)';
              
              figure;plot(Freqs, log(BLFFTICA)'); title('EC')
              
              
              
                Weights = EEG.icaweights*EEG.icasphere;
            ICAEEGSD = Weights * EEG.data;
            SDKeep = ~[EEG.reject.gcompreject];
              ICAEEGSD_Clean = ICAEEGSD(SDKeep, :);
              
              WelchWindow = 10;
              Freqs = 2.5:.1:40; 
              
              SDFFTICA =  pwelch( ICAEEGSD_Clean', WelchWindow*EEG.srate, [], Freqs, EEG.srate)';
              
              figure;plot(Freqs, log(SDFFTICA)'); title('EO')
              
              
              
               
                Weights = EEG.icaweights*EEG.icasphere;
            ICAEEGMWT = Weights * EEG.data;
            MWTKeep = ~[EEG.reject.gcompreject];
              ICAEEGMWT_Clean = ICAEEGMWT(MWTKeep, :);
              
              
              MWTFFTICA =  pwelch( ICAEEGMWT_Clean', WelchWindow*EEG.srate, [], Freqs, EEG.srate)';
              
              figure;plot(Freqs, log(MWTFFTICA)'); title('MWT')
              
              
              figure
              subplot(1, 3, 1)
                topoplot(BLEEG.icawinv(:, 3), BLEEG.chanlocs, ...
            'style', 'map', 'headrad', 'rim', 'gridscale', 200, 'maplimits', [-3 3]);
        title('EC')
     
                      subplot(1, 3, 2)
                topoplot(SDEEG.icawinv(:, 10), SDEEG.chanlocs, ...
            'style', 'map', 'headrad', 'rim', 'gridscale', 200, 'maplimits', [-3 3]);
        title('EO')
   subplot(1, 3, 3)
                topoplot(MWTEEG.icawinv(:, 2), MWTEEG.chanlocs, ...
            'style', 'map', 'headrad', 'rim', 'gridscale', 200, 'maplimits', [-3 3]);
        title('MWT')
  
        colormap(rdbu(11))
        
        
        BLFFT =  pwelch( BLEEG.data', WelchWindow*EEG.srate, [], Freqs, EEG.srate)';     
               SDFFT =  pwelch( SDEEG.data', WelchWindow*EEG.srate, [], Freqs, EEG.srate)';     
     
         UnThetaBL = pop_subcomp(BLEEG, 3);
         UnThetaSD = pop_subcomp(SDEEG, 10);
             BLunTFFT =  pwelch(  UnThetaBL.data', WelchWindow*EEG.srate, [], Freqs, EEG.srate)';     
               SDunTFFT =  pwelch( UnThetaSD.data', WelchWindow*EEG.srate, [], Freqs, EEG.srate)';     
         
                  figure
        subplot(1, 2, 1)
        hold on
        plot(Freqs, log(mean(BLFFT(10:20, :), 1)))
         plot(Freqs, log(mean(SDFFT(10:20, :))))
         legend({'BL', 'SD'})
         title('Raw data')
           subplot(1, 2, 2)
        hold on
        plot(Freqs, log(mean(BLunTFFT(10:20, :))))
         plot(Freqs, log(mean(SDunTFFT(10:20, :))))
             legend({'BL', 'SD'})
              title('w/o theta')
              
              
              figure
              hold on
              plot(Freqs, log(BLFFTICA(7, :)))
                  plot(Freqs, log(SDFFTICA(3, :)))
%                       plot(Freqs, log(MWTFFTICA(1, :)))
%                       legend({'BL', 'SD', 'MWT'})
legend({'EC', 'EO'})


All = struct();
All.All = [2, 12];

Bands = struct();
Bands.Delta = [2, 5];
Bands.Theta = [4, 8];
Bands.Alpha = [8, 12];
SDEEGC = SDEEG;
SDEEGC.data(1:size(ICAEEGSD_Clean, 1), :) = ICAEEGSD_Clean;
[HilbertPower, Phase] = HilbertBands(SDEEGC, Bands, 'matrix', false);


eegplot(ICAEEGSD_Clean, 'srate', EEG.srate, 'spacing', 10, 'winlength', 10, 'data2', HilbertPower(1:size(ICAEEGSD_Clean, 1), :))
