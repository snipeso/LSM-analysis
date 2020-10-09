function [ConvAll, R] = SnipletDecomposition(Data, Sniplets, Overlap)
% if sniplets is a matrix, treat each row as a sniplet
% check that Sniplets is small enough

% if Sniplets is 1 value (the window length in points), run normally
if numel(Sniplets) == 1
    SnipletWindow = Sniplets;
    StartGap = round((1-Overlap)*SnipletWindow);
    Starts = 1:StartGap:numel(Data)-SnipletWindow;
    Stops = Starts+SnipletWindow-1;
    
    Sniplets = nan(numel(Starts), SnipletWindow);
    for Indx_S = 1:numel(Starts)
        Sniplets(Indx_S, :) = Data(Starts(Indx_S):Stops(Indx_S));
    end
else
    Gap = size(Sniplets, 2);
    Starts = 1:Gap:numel(Data)-Gap;
    Stops = Starts+Gap-1;
end

[nSniplets, SniPoints] = size(Sniplets);

ConvAll = nan(nSniplets, numel(Data));
R =  nan(nSniplets);

halfsnipletsize = ceil(SniPoints/2);
G = gausswin(SniPoints);
Sniplets = G'.*Sniplets;

for Indx_S1 = 1:nSniplets
    
    
    %
    % NFFT = numel(IC) + numel(Sniplet) - 1;
    % FFTIC = fft(IC, NFFT);
    %  FFTSni = fft(Sniplet, NFFT);
    %  ift = ifft(FFTIC.*FFTSni, NFFT);
    %  result2 = real(ift(halfsnipletsize:end-halfsnipletsize+1));
    % % Conv = ifft(fft(IC, nIC) .* fft(Snipet, nSni), nIC);
    
    Sniplet1 = Sniplets(Indx_S1, :);
%     Conv = conv(Data, Sniplet1, 'same');

Conv = xcorr(Data, Sniplet1);
Conv = Conv(numel(Data):end);
    
%     ConvAll(Indx_S1, :) = zscore(Conv);
       ConvAll(Indx_S1, :) = Conv;
        ConvAll(Indx_S1, :) = 1./(1+exp(Conv.*-.001));
        A=1;
    
%     for Indx_S2 = Indx_S1:nSniplets
% %         Range_S2 = Starts(Indx_S2):Stops(Indx_S2);
% %         C = G'.*Conv(Range_S2);
% %         [~, I] = max(C);
% %         Indx = Range_S2(I);
% %         Window_S2 = [Indx - halfsnipletsize, Indx + halfsnipletsize-1];
% %         
% %         if Window_S2(1)<1 || Window_S2(2)>numel(Data)
% %             continue
% %         end
% %         
% %         Sniplet2 = G'.*Data(Window_S2(1):Window_S2(2));
% 
% Sniplet2 = Data(Starts(Indx_S2):Stops(Indx_S2));
% 
% SR = xcorr(Sniplet1, Sniplet2, 'normalized');
%         
% %         if Indx_S1 == Indx_S2
%             figure; 
%             subplot(2, 1, 1)
%             plot(Sniplets(Indx_S1, :))
%             hold on
%             plot(Sniplet2)
%             subplot(2, 1, 2)
%             plot(Conv(Range_S2))
%             hold on
%             plot(C)
%           scatter(I, C(I), 'filled')
%             
%             A= 1;
% %         end
%         
%         R(Indx_S1, Indx_S2) = corr(Sniplet1', Sniplet2');
%     end
%     
end

% ConvAll = zscore(ConvAll);

Hilby = hilbert(ConvAll')';
ConvAll = abs(Hilby);

% sfotmax to get beteen 0 and 1

