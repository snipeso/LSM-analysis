function cm_data = palehsv(m)

Tot_Colors = 256;
cm = [linspace(0, (Tot_Colors -1)/Tot_Colors,Tot_Colors)', ...
    ones(Tot_Colors, 1)*0.2, ...
    ones(Tot_Colors, 1)];

cm = hsv2rgb(cm);

if nargin < 1
    cm_data = cm;
else
    hsv=rgb2hsv(cm);
    cm_data=interp1(linspace(0,1,size(cm,1)),hsv,linspace(0,1,m));
    cm_data=hsv2rgb(cm_data);
end
end

