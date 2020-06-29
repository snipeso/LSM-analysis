function cm_data = palejet(m)

cm = colormap(jet(m));

cm = rgb2hsv(cm);

cm(:, 2) = cm(:, 2)./5; % adjust saturation

cm(:, 3) = cm(:, 3) + ((1-cm(:, 3))./5); % adjust value

    cm_data = hsv2rgb(cm);
