Colors = palehsv(7 + 1);
Matrix = ClassicMatrix;
% figure
% hold on
% for Indx = 1:7
%     plot(diff(Matrix(Indx, :)), 'Color', Colors(Indx, :), 'LineWidth', 1)
% end
% plot(mean(diff(Matrix(Indx, :)), 1), 'Color', 'k', 'LineWidth', 3)
% title('Classic')
% ylim([-2.5, 1])

Changes = diff(Matrix, 1,2);
[~, p] = ttest(Changes(:));
disp(['ttest p-value: ', num2str(p)])

p = signtest(diff(sign(Changes),1,2));
disp(['signtest p-value: ', num2str(p)])

% correlation
Sessions = repmat([1 2 3], 7, 1);

[r, p] = corr(Matrix(:), Sessions(:));
disp(['r: ', num2str(r), ' p-value: ', num2str(p)])

figure
hold on
for Indx = 1:7
    for Indx_S = 1:3
    scatter(Matrix(Indx, Indx_S), Indx_S,[], Colors(Indx, :), 'filled')
    end
end
plot(mean(diff(Matrix(Indx, :)), 1), 'Color', 'k', 'LineWidth', 3)
title('Classic')
ylim([-2.5, 1])
