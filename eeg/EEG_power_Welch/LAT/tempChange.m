function tempChange(A, Freqs, What)

FreqsTheta =  dsearchn(Freqs', [4, 8]');
FreqsCustomTheta =  dsearchn(Freqs', [3, 6]');

ThetaBL = nanmean(A(1, FreqsTheta(1):FreqsTheta(2)));
ThetaSD =  nanmean(A(2, FreqsTheta(1):FreqsTheta(2)));
Change = 100*(ThetaSD-ThetaBL)/ThetaBL;
ThetaBL = nanmean(A(1, FreqsCustomTheta(1):FreqsCustomTheta(2)));
ThetaSD =  nanmean(A(2, FreqsCustomTheta(1):FreqsCustomTheta(2)));
ChangeCustom = 100*(ThetaSD-ThetaBL)/ThetaBL;
disp(['Percent change ', What, ' theta band: ', num2str(round(Change)), '%; and custom range: ', num2str(round(ChangeCustom)), '%'])

ThetaBL = A(1, FreqsTheta(1):FreqsTheta(2));
ThetaSD =  A(2, FreqsTheta(1):FreqsTheta(2));
Change = nanmean(100*(ThetaSD-ThetaBL)./ThetaBL);
ThetaBL = A(1, FreqsCustomTheta(1):FreqsCustomTheta(2));
ThetaSD =  A(2, FreqsCustomTheta(1):FreqsCustomTheta(2));
ChangeCustom = nanmean(100*(ThetaSD-ThetaBL)./ThetaBL);
disp(['Average percent change ', What, ' theta: ', num2str(round(Change)), '%; and custom range: ', num2str(round(ChangeCustom)), '%'])

