function WindowedData = windows2data(Data, Windows)

WindowedData = nan(size(Data));

Indexes = 1:numel(Data);

Keep = any(Indexes>=Windows(:, 1) & Indexes<=Windows(:, 2));

WindowedData(Keep) = Data(Keep);
