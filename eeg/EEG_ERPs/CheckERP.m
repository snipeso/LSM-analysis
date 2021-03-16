function CheckERP(Data, Point, Chanlocs, Lims)


  for Indx_P = 1:size(Data, 1)
      for Indx_C = 1:size(Data, 2)
        Data(Indx_P, Indx_C, :) = smooth(Data(Indx_P, Indx_C, :), 100);
      end
  end
    
figure('units','normalized','outerposition',[0 0 1 1])
for Indx_P = 1:size(Data, 1)
    D = squeeze(Data(Indx_P, :, Point));
    
    
    
    subplot(3, 4, Indx_P)
    topoplot(D, Chanlocs,  'maplimits', Lims, 'colormap', rdbu);
    title(num2str(Indx_P))
    
end
