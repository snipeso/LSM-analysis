function Colors = ColorGradient(Color, Tot, Direction)
% direction can be either dark or light

Color = rgb2hsv(Color);

switch Direction
    case 'dark'
    case 'light'
        
        SatShift = Color(2)/Tot;
        LumShift = (1-Color(3))/Tot;
        
        Colors = [Color(1)*ones(Tot, 1), linspace(SatShift, Color(2), Tot)', flip(linspace( Color(3), 1-LumShift, Tot))' ];
end

Colors = hsv2rgb(Colors);