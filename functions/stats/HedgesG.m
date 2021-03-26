function [g, CI] = HedgesG(Row1, Row2)
statsHedges = mes(Row1, Row2, 'hedgesg', 'isDep', 1, 'nBoot', 1000);

g = statsHedges.hedgesg;
CI = statsHedges.hedgesgCi;
