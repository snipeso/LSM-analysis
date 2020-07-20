function cm_data = paleunirainbow(m)


cm = [
     0.9725    0.8510    0.8392;
    0.9725    0.8549    0.8392;
    0.9765    0.8549    0.8353;
    0.9765    0.8549    0.8353;
    0.9765    0.8588    0.8353;
    0.9765    0.8588    0.8353;
    0.9765    0.8627    0.8353;
    0.9765    0.8627    0.8353;
    0.9804    0.8667    0.8353;
    0.9804    0.8667    0.8353;
    0.9804    0.8706    0.8353;
    0.9804    0.8706    0.8353;
    0.9804    0.8745    0.8353;
    0.9804    0.8745    0.8353;
    0.9843    0.8784    0.8353;
    0.9843    0.8784    0.8353;
    0.9843    0.8824    0.8353;
    0.9843    0.8824    0.8353;
    0.9843    0.8824    0.8353;
    0.9843    0.8863    0.8353;
    0.9882    0.8863    0.8314;
    0.9882    0.8902    0.8314;
    0.9882    0.8902    0.8314;
    0.9882    0.8941    0.8314;
    0.9882    0.8941    0.8314;
    0.9882    0.8980    0.8314;
    0.9922    0.8980    0.8314;
    0.9922    0.9020    0.8314;
    0.9922    0.9020    0.8275;
    0.9922    0.9059    0.8275;
    0.9922    0.9059    0.8235;
    0.9922    0.9059    0.8235;
    0.9922    0.9098    0.8235;
    0.9922    0.9098    0.8196;
    0.9882    0.9137    0.8196;
    0.9882    0.9137    0.8157;
    0.9882    0.9176    0.8157;
    0.9882    0.9176    0.8118;
    0.9882    0.9176    0.8118;
    0.9882    0.9216    0.8118;
    0.9882    0.9216    0.8078;
    0.9882    0.9255    0.8078;
    0.9882    0.9255    0.8039;
    0.9882    0.9294    0.8039;
    0.9882    0.9294    0.8000;
    0.9882    0.9333    0.8000;
    0.9882    0.9333    0.7961;
    0.9882    0.9333    0.7961;
    0.9882    0.9373    0.7922;
    0.9882    0.9373    0.7922;
    0.9882    0.9412    0.7922;
    0.9882    0.9412    0.7882;
    0.9882    0.9451    0.7882;
    0.9882    0.9451    0.7843;
    0.9882    0.9451    0.7843;
    0.9882    0.9490    0.7804;
    0.9882    0.9490    0.7804;
    0.9882    0.9490    0.7804;
    0.9843    0.9490    0.7804;
    0.9843    0.9490    0.7804;
    0.9843    0.9490    0.7843;
    0.9843    0.9490    0.7843;
    0.9804    0.9529    0.7843;
    0.9804    0.9529    0.7843;
    0.9804    0.9529    0.7843;
    0.9765    0.9529    0.7843;
    0.9765    0.9529    0.7843;
    0.9765    0.9529    0.7843;
    0.9765    0.9529    0.7843;
    0.9725    0.9529    0.7882;
    0.9725    0.9529    0.7882;
    0.9725    0.9529    0.7882;
    0.9686    0.9529    0.7882;
    0.9686    0.9529    0.7882;
    0.9686    0.9529    0.7882;
    0.9686    0.9529    0.7882;
    0.9647    0.9569    0.7882;
    0.9647    0.9569    0.7882;
    0.9647    0.9569    0.7922;
    0.9608    0.9569    0.7922;
    0.9608    0.9569    0.7922;
    0.9608    0.9569    0.7922;
    0.9569    0.9569    0.7922;
    0.9569    0.9569    0.7922;
    0.9529    0.9569    0.7922;
    0.9529    0.9529    0.7922;
    0.9490    0.9529    0.7882;
    0.9490    0.9529    0.7882;
    0.9451    0.9529    0.7882;
    0.9451    0.9529    0.7882;
    0.9412    0.9529    0.7882;
    0.9412    0.9529    0.7882;
    0.9373    0.9529    0.7882;
    0.9373    0.9490    0.7882;
    0.9333    0.9490    0.7882;
    0.9333    0.9490    0.7882;
    0.9294    0.9490    0.7882;
    0.9255    0.9490    0.7882;
    0.9255    0.9490    0.7843;
    0.9216    0.9490    0.7843;
    0.9216    0.9490    0.7843;
    0.9176    0.9451    0.7843;
    0.9176    0.9451    0.7843;
    0.9137    0.9451    0.7843;
    0.9137    0.9451    0.7843;
    0.9098    0.9451    0.7843;
    0.9059    0.9451    0.7843;
    0.9020    0.9451    0.7882;
    0.8941    0.9451    0.7922;
    0.8902    0.9412    0.7961;
    0.8863    0.9412    0.8000;
    0.8784    0.9412    0.8039;
    0.8745    0.9412    0.8039;
    0.8706    0.9412    0.8078;
    0.8627    0.9412    0.8118;
    0.8588    0.9412    0.8157;
    0.8510    0.9412    0.8196;
    0.8471    0.9412    0.8235;
    0.8392    0.9412    0.8235;
    0.8353    0.9373    0.8275;
    0.8314    0.9373    0.8314;
    0.8235    0.9373    0.8353;
    0.8196    0.9373    0.8392;
    0.8157    0.9373    0.8431;
    0.8078    0.9373    0.8431;
    0.8039    0.9373    0.8471;
    0.7961    0.9373    0.8510;
    0.7922    0.9373    0.8549;
    0.7922    0.9333    0.8588;
    0.7922    0.9333    0.8588;
    0.7882    0.9294    0.8627;
    0.7882    0.9294    0.8627;
    0.7882    0.9255    0.8667;
    0.7882    0.9255    0.8706;
    0.7882    0.9216    0.8706;
    0.7843    0.9216    0.8745;
    0.7843    0.9176    0.8745;
    0.7843    0.9176    0.8784;
    0.7843    0.9137    0.8824;
    0.7804    0.9137    0.8824;
    0.7804    0.9137    0.8863;
    0.7804    0.9098    0.8902;
    0.7804    0.9098    0.8902;
    0.7765    0.9059    0.8941;
    0.7765    0.9059    0.8980;
    0.7765    0.9020    0.8980;
    0.7765    0.9020    0.9020;
    0.7765    0.8980    0.9020;
    0.7725    0.8980    0.9059;
    0.7725    0.8941    0.9098;
    0.7725    0.8941    0.9098;
    0.7725    0.8902    0.9137;
    0.7725    0.8902    0.9176;
    0.7725    0.8863    0.9176;
    0.7765    0.8863    0.9216;
    0.7765    0.8824    0.9216;
    0.7804    0.8824    0.9255;
    0.7804    0.8784    0.9294;
    0.7843    0.8745    0.9294;
    0.7843    0.8745    0.9333;
    0.7882    0.8706    0.9373;
    0.7882    0.8706    0.9373;
    0.7922    0.8667    0.9412;
    0.7922    0.8667    0.9412;
    0.7961    0.8627    0.9451;
    0.7961    0.8627    0.9490;
    0.8000    0.8588    0.9490;
    0.8000    0.8549    0.9529;
    0.8039    0.8549    0.9569;
    0.8039    0.8510    0.9569;
    0.8078    0.8510    0.9608;
    0.8118    0.8471    0.9608;
    0.8118    0.8471    0.9647;
    0.8157    0.8431    0.9686;
    0.8157    0.8431    0.9686;
    0.8196    0.8392    0.9725;
    0.8196    0.8392    0.9725;
    0.8235    0.8392    0.9725;
    0.8235    0.8392    0.9725;
    0.8275    0.8392    0.9725;
    0.8275    0.8353    0.9725;
    0.8275    0.8353    0.9725;
    0.8314    0.8353    0.9725;
    0.8314    0.8353    0.9725;
    0.8353    0.8353    0.9725;
    0.8353    0.8353    0.9725;
    0.8392    0.8353    0.9725;
    0.8392    0.8353    0.9725;
    0.8431    0.8353    0.9725;
    0.8431    0.8353    0.9725;
    0.8471    0.8353    0.9725;
    0.8471    0.8353    0.9686;
    0.8510    0.8353    0.9686;
    0.8510    0.8353    0.9686;
    0.8549    0.8353    0.9686;
    0.8549    0.8353    0.9686;
    0.8588    0.8353    0.9686;
    0.8588    0.8353    0.9686;
    0.8627    0.8353    0.9686;
    0.8627    0.8353    0.9686;
    0.8667    0.8353    0.9686;
    0.8667    0.8353    0.9686;
    0.8706    0.8353    0.9686;
    0.8706    0.8353    0.9686;
    0.8745    0.8353    0.9686;
    0.8784    0.8353    0.9686;
    0.8784    0.8353    0.9686;
    0.8824    0.8353    0.9686;
    0.8824    0.8353    0.9686;
    0.8863    0.8353    0.9686;
    0.8863    0.8353    0.9686;
    0.8902    0.8353    0.9686;
    0.8941    0.8353    0.9686;
    0.8941    0.8353    0.9686;
    0.8980    0.8353    0.9686;
    0.8980    0.8353    0.9686;
    0.9020    0.8353    0.9686;
    0.9020    0.8353    0.9686;
    0.9059    0.8353    0.9686;
    0.9059    0.8353    0.9686;
    0.9098    0.8353    0.9686;
    0.9137    0.8353    0.9686;
    0.9137    0.8353    0.9686;
    0.9176    0.8353    0.9686;
    0.9176    0.8353    0.9686;
    0.9216    0.8353    0.9686;
    0.9216    0.8353    0.9686;
    0.9255    0.8353    0.9686;
    0.9294    0.8353    0.9686;
    0.9294    0.8353    0.9686;
    0.9333    0.8353    0.9686;
    0.9333    0.8353    0.9686;
    0.9373    0.8353    0.9686;
    0.9373    0.8353    0.9647;
    0.9373    0.8392    0.9647;
    0.9412    0.8392    0.9608;
    0.9412    0.8431    0.9608;
    0.9412    0.8431    0.9608;
    0.9451    0.8431    0.9569;
    0.9451    0.8471    0.9569;
    0.9451    0.8471    0.9529;
    0.9490    0.8471    0.9529;
    0.9490    0.8510    0.9490;
    0.9490    0.8510    0.9490;
    0.9529    0.8549    0.9490;
    0.9529    0.8549    0.9451;
    0.9569    0.8549    0.9451;
    0.9569    0.8588    0.9412;
    0.9569    0.8588    0.9412;
    0.9608    0.8588    0.9373;
    0.9608    0.8627    0.9373;
    0.9608    0.8627    0.9373;
    0.9647    0.8667    0.9333;
    0.9647    0.8667    0.9333;
    0.9647    0.8667    0.9294;
    0.9686    0.8706    0.9294;
];



if nargin < 1
    cm_data = cm;
else
    hsv=rgb2hsv(cm);
    cm_data=interp1(linspace(0,1,size(cm,1)),hsv,linspace(0,1,m));
    cm_data=hsv2rgb(cm_data);
    
end
end