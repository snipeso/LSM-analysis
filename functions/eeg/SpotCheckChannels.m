function SpotCheckChannels(Data1, fs1, Data2, fs2, Channels)

% time vectors
t1 = linspace(0, size(Data1, 2)/fs1, size(Data1, 2));
t2 = linspace(0, size(Data2, 2)/fs2, size(Data2, 2));

figure
for Indx_Ch = 1:numel(Channels) % plot a subplot for each channel
    subplot(numel(Channels), 1, Indx_Ch)
    hold on
    plot(t1, Data1(Indx_Ch, :), 'k')
    plot(t2, Data2(Indx_Ch, :), 'r')
    title([num2str(Channels(Indx_Ch))])
end

figure
for Indx_Ch = 1:numel(Channels) % plot a subplot for each channel
    subplot(numel(Channels), 1, Indx_Ch)
    hold on
    
    x = Data1(Indx_Ch, :);
    [pxx,f] = pwelch(x,length(x),[],length(x),fs1);
    plot(f, log(pxx), 'k')
    x =  Data2(Indx_Ch, :);
    [pxx,f] = pwelch(x,length(x),[],length(x),fs2);
    plot(f, log(pxx), 'r')
    title([ num2str(Channels(Indx_Ch))])
end
