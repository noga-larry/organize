function data = getBehavior (data,maestroPath);

CALIBRATE_VEL = 10.8826;
CALIBRATE_POS = 40;


for t=1:length(data.trials)
data_raw = readcxdata (  [maestroPath '\'  data.info.session ...
   '\' data.trials(t).maestro_name]);

% get behavior
%  1: horizonal position
%  2: vertical position
%  3: horizonal velocity
%  4: vertical velocity

data.trials(t).hPos = data_raw.data(1,:)/CALIBRATE_POS;
data.trials(t).vPos = data_raw.data(2,:)/CALIBRATE_POS;
data.trials(t).hVel = data_raw.data(3,:)/CALIBRATE_VEL;
data.trials(t).vVel = data_raw.data(4,:)/CALIBRATE_VEL;
end
