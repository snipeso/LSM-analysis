function [d] = CohenD(Data1, Data2)

M1 = nanmean(Data1);

M2 = nanmean(Data2);

SD1 = nanstd(Data1);
SD2 = nanstd(Data2);

% d = (M1-M2)/sqrt((SD1^2 + SD2^2)/2);
% d = (M1-M2);
d= sqrt((SD1^2 + SD2^2)/2);

d=abs(d);