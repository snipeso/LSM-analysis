
clear
clc

SPrepw = '23:00'; % time of preparing to sleep work "I actually get ready to fall asleep at"
SPrepf = '23:00'; % time of preparing to sleep free
SLatw = 15; % sleep latency on week days
SLatf = 15; % sleep latency on free days
SEw = '07:45'; % sleep end week days
SEf = '07:45'; % sleep end free days
Alarmw = false; % whether alarm is used on work days
Alarmf = false; % whether alarm is used on free days
SIw = 0; % sleep intertia week days
SIf = 0; % sleep intertia free days
WD= 5; % number of work days
FD= 7-WD; % number 
BTw = 0; % time of going to bed on work days
BTf = 0; % time of going to bed on free days

SPrepf = time2float(SPrepf);
SPrepw = time2float(SPrepw);
SEf = time2float(SEf);
SEw =  time2float(SEw);
SOf = mod(SPrepf + SLatf/60, 24); % sleep onset on free days
SOw = mod(SPrepw + SLatw/60, 24); % sleep onset on work days
SDw = mod((SEw + 24) - SOw, 24); % sleep duration on work days; needs to calculate based on stupid clock things
SDf =  mod((SEf + 24) - SOf, 24);% sleep duration free days
MSF = SOf + SDf / 2; % mid sleep on free days TODO, see if parantheses needed

% corrects for accumulated sleep debt
if SDf <= SDw % if sleep duration on free days is same or equal to work days, all ist gut
    Score = MSF;
else
    SDweek = (SDw * WD + SDf * FD)/7; % average weekly sleep duration
    Score = MSF-(SDf - SDweek)/2;
end

disp(['Midsleep on free days: ', float2time(Score), '; Score: ', num2str(mod(Score, 24))])


function float = time2float(time)
%%% takes HH:MM in 24h clock
H = str2double(time(1:2));
M = str2double(time(4:5))/60;

float = H + M;

end

function time = float2time(float)

M = mod(float, 1);
H = float-M;

time = [num2str(H, '%02.f'), ':', num2str(M, '%02.f')];

end