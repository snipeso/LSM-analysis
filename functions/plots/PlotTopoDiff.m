function PlotTopoDiff(Matrix1, Matrix2, Chanlocs, CLims, Format)
% matrix is participant x ch

% get t values
[~, p, ~, stats] = ttest((Matrix2 - Matrix1));
% [~, Sig] = fdr(p, .05);
Sig = p< 0.01;
Diff = stats.tstat';


% % get cohen's d
%     M1 = nanmean(Matrix1, 1);
%     M2 = nanmean(Matrix2, 1);
% SD_pooled = sqrt((nanstd(Matrix1, 1).^2 + nanstd(Matrix2, 1).^2)/2);
% Diff = (M2-M1)./SD_pooled;

% Diff = (nanmean(Matrix1, 1) - nanmean(Matrix2, 1));
CLabel = 't values';
Indexes = 1:numel(Chanlocs);


if isempty(CLims)
    Max = max(abs([quantile(Diff(:), .01), quantile(Diff(:), .99)]));
    CLims = [-Max Max];
end

topoplot(Diff, Chanlocs, 'maplimits', CLims, ...
    'style', 'map', 'headrad', 'rim', 'gridscale', 500, 'emarker2', {Indexes(logical(Sig)), 'o', 'w', 3, .01});
h = colorbar;
ylabel(h, CLabel, 'FontName', Format.FontName, 'FontSize', 14)
% set(gca, 'FontSize', 14, 'FontName', Format.FontName)
set(gca, 'FontName', Format.FontName)
colormap(Format.Colormap.Divergent)


% TODO: seperately plot markers if significiant for p<.05, and for cluster
% correction