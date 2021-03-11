function GMFP_Data = GMFP(Data)
% Data is Participant x ch x time
 [nP, nCh, nT] = size(Data);
 
 GMFP_Data = nan(nP, nT);
 
for Indx_P = 1:nP
   V =  squeeze(Data(Indx_P, :, :));
   Mean = nanmean(V, 1);
   
    GMFP_Data(Indx_P, :) = sqrt(nansum((V-Mean).^2, 1)/nCh);
end
