function [power,ff, i1, i2] = Burgy(data, p, t, epochl, fs, tit, toPlot, seg)
%
%   data: EEG data
%   p: order of AR model
%   t: start time in s to analyze data 
%      t=0 to start at beginning
%   epochl: length of data segment to analyze (s)
%   fs: sampling rate
%   tit: title for plot
%
% August 7, 2012, pa; last modification: August 10, 2012, pa
%
% May 2014, js


t1=t; i1=t1*fs+1; i2=i1+epochl*fs-1;

% parameters
epoch=1; % epoch length in s for calculating spectra
seg_length=epoch*fs; % 1s segments
shift=1/seg; % shift as proportion of segment length

t1=round(t1);

shift1=round(fs*shift); % shift in samples
maxep=round((epochl-(epoch*(1-shift)))/shift); 

ff=(0:1/seg:fs/2); % f axis for AR spectra 
Peeg=zeros(maxep,seg*fs/2+1);
offset=t1*fs; 


for ep=1:maxep
    ind1=offset+(ep-1)*shift1+1; ind2=offset+(ep-1)*shift1+seg_length;
    if ind2>numel(data)
        ind2 = numel(data);
    end
    %
    try
    Pxx= pburg(data(ind1:ind2),p,ff,fs);
    catch
        a=1
    end
    Peeg(ep,:)=Pxx;
    
end

power = zeros(size(Peeg));
power = Peeg;


% plot spectra
fmax = 30;
imax=ceil(seg*fmax);


if (toPlot==1)
    
    h = figure; %('visible','off')
    
    a1 = subplot(2,1,1)
    
    %plot raw EEG
    da = data(i1:i2);
    p1=plot((1:length(da))/fs,da);
    title(tit);
    ylabel('O2M1 (�V)');
    
    a2 = subplot(2,1,2)
    
    p2=imagesc(((1:size(Peeg,1))+seg/2)/seg,ff(1:imax),10*log10(Peeg(:,1:imax)'),[-20,30]);
    set(gca,'YLim',[0 fmax]);
    colormap('jet');
    
    axis xy
    xlabel('t (s)')
    ylabel('f (Hz)');
    grid on;
    
    linkaxes([a1,a2], 'x');
 
    
end


end

