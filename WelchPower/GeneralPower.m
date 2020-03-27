
clear
clc
close all

wp_Parameters


[allFFT, Categories] = LoadAll(Paths.powerdata);


Sessions = unique(Categories(3, :));
Sessions(strcmpi(Sessions, 'extras')) = [];
Sessions(contains(Sessions, 'Comp')) = [];
Participants = unique(Categories(1, :));

ChanLabels = {allFFT(1).Chanlocs.labels};


figure
Colors = {[ 0.00000  0.43922  0.36863], ... %BL
    [0.58039  0.00000  0.61961],... % post
    [1.00000  0.61961  0.38039], ... % pre
    [1.00000  0.65882  0.76863], ... %session1
    [ 1.00000  0.41961  0.54510], ... %s2B1
    [0.98039  0.00000  0.39216], ... %s2b2
    [ 0.76078  0.00000  0.32941], ... %S2b3
    };
Ch = [find(strcmp(ChanLabels, '10')), find(strcmp(ChanLabels, '70'))];
for Indx_Ch = 1:numel(Ch)
    subplot(1, 2, Indx_Ch)
    hold on
    for Indx_S = 1:numel(Sessions)
        All_Averages = nan(numel(Participants), numel(allFFT(1).Freqs));
        Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
        
        for Indx_P = 2:numel(Session_Indexes)
            All_Averages(Indx_P, :) = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(Ch(Indx_Ch), :, :), 3);
        end
        
        plot(allFFT(1).Freqs, log(nanmean(All_Averages, 1)), 'LineWidth', 2, 'Color', Colors{Indx_S})
    end
    legend(Sessions)
    title(['Power in Ch', ChanLabels(Ch(Indx_Ch))])
    ylim([-2, 1.5])
    xlim([1, 20])
    xlabel('Frequency (Hz)')
    ylabel('Power Density')
end

%



% plot S1 and S2 of comp vs beam
Sessions = {'BaselineBeam', 'Session1Beam', 'Session2Beam1', 'BaselineComp', 'Session1Comp', 'Session2Comp'};
Colors = {[ 1.00000  0.54118  0.83922], [ 1.00000  0.38039  0.83529], [ 0.85882  0.00000  0.60392], ...
    [ 0.00000  0.70196  0.74118], [ 0.00000  0.57255  0.65882], [  0.00000  0.47843  0.60000]};
figure
Ch = [10, 70];
for Indx_Ch = 1:numel(Ch)
    subplot(1, 2, Indx_Ch)
    hold on
    for Indx_S = 1:numel(Sessions)
        All_Averages = nan(numel(Participants), numel(allFFT(1).Freqs));
        Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
        for Indx_P = 2:numel(Session_Indexes)
            All_Averages(Indx_P, :) = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(Ch(Indx_Ch), :, :), 3);
        end
        
        plot(allFFT(1).Freqs, log(nanmean(All_Averages, 1)), 'Color', Colors{Indx_S}, 'LineWidth', 2)
    end
    legend(Sessions)
    title(['Power in Ch', num2str(Ch(Indx_Ch))])
    ylim([-2, 1.5])
    xlim([1, 20])
    xlabel('Frequency (Hz)')
    ylabel('Power Density')
end


% plot topoplots
Freqs = [1:15];
Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1','Session2Beam2', 'Session2Beam3', 'MainPost'};
FreqsIndx =  dsearchn( allFFT(1).Freqs', Freqs');
load('StandardChanlocs128.mat')
Indx=1;
figure
for Indx_S = 1:numel(Sessions)
    for Indx_F = 1:numel(Freqs)
        
        All_Channels = nan(numel(Participants),size(allFFT(1).FFT, 1));
        Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
        
        for Indx_P = 2:numel(Session_Indexes)
            All_Channels(Indx_P, :) = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(:, FreqsIndx(Indx_F), :), 3);
        end
        subplot(numel(Sessions), numel(Freqs), Indx)
        topoplot(log(nanmean(All_Channels, 1)), allFFT(1).Chanlocs, 'maplimits', [-2, 1], 'style', 'map', 'headrad', 'rim')
        Indx = Indx+1;
        if Indx<=numel(Freqs)
            title([num2str(Freqs(Indx_F)), 'Hz'])
        end
    end
end


% plot sides
% Freqs = [1:15];
% Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1','Session2Beam2', 'Session2Beam3', 'MainPost'};
% FreqsIndx =  dsearchn( allFFT(1).Freqs', Freqs');
% 
% for Indx_L = 1:2
%     Indx=1;
%     figure
%     for Indx_S = 1:numel(Sessions)
%         for Indx_F = 1:numel(Freqs)
%             
%             All_Channels = nan(numel(Participants),size(allFFT(1).FFT, 1));
%             Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
%             
%             for Indx_P = 1:numel(Session_Indexes)
%                 All_Channels(Indx_P, :) = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(:, FreqsIndx(Indx_F), (allFFT(Session_Indexes(Indx_P)).Blocks ==Indx_L)), 3);
%             end
%             subplot(numel(Sessions), numel(Freqs), Indx)
%             topoplot(log(nanmean(All_Channels, 1)), allFFT(1).Chanlocs, 'maplimits', [-2, 1.5], 'style', 'map', 'headrad', 'rim')
%             Indx = Indx+1;
%             if Indx<=numel(Freqs)
%                 title([num2str(Freqs(Indx_F)), 'Hz'])
%             end
%         end
%     end
%     
% end

% plot difference
Freqs = [1:15];
Sessions = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1','Session2Beam2', 'Session2Beam3', 'MainPost'};
FreqsIndx =  dsearchn( allFFT(1).Freqs', Freqs');


Indx=1;
figure
for Indx_S = 1:numel(Sessions)
    for Indx_F = 1:numel(Freqs)
        
        All_Channels = nan(numel(Participants),size(allFFT(1).FFT, 1));
        Session_Indexes = find(strcmp(Categories(3, :), Sessions{Indx_S}));
        
        for Indx_P = 2:numel(Session_Indexes)
            LeftTopo = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(:, FreqsIndx(Indx_F), (allFFT(Session_Indexes(Indx_P)).Blocks ==1)), 3);
            RightTopo = nanmean(allFFT(Session_Indexes(Indx_P)).FFT(:, FreqsIndx(Indx_F), (allFFT(Session_Indexes(Indx_P)).Blocks ==2)), 3);
            All_Channels(Indx_P, :) = (log(LeftTopo)-log(RightTopo))./log(RightTopo);
        end
        subplot(numel(Sessions), numel(Freqs), Indx)
        topoplot(nanmean(All_Channels, 1), allFFT(1).Chanlocs, 'maplimits', [-.2, .2], 'style', 'map', 'headrad', 'rim')
        Indx = Indx+1;
        if Indx<=numel(Freqs)
            title([num2str(Freqs(Indx_F)), 'Hz'])
        end
    end
end

