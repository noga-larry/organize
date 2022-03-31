function [behaviorData] = getBehaviorShadowFile(data,MaestroPath)


CALIBRATE_VEL = 10.8826;
CALIBRATE_POS = 40;

behaviorData.info = data.info;


    

for t=1:length(data.trials)
    data_raw = readcxdata (  [MaestroPath '\' data.info.monkey '\'  data.info.session ...
        '\' data.trials(t).maestro_name]);
    
    behaviorData.trials(t).maestro_name = data.trials(t).maestro_name;
    
    % get behavior
    %  1: horizonal position
    %  2: vertical position
    %  3: horizonal velocity
    %  4: vertical velocity
    
    behaviorData.trials(t).hPos = data_raw.data(1,:)/CALIBRATE_POS;
    behaviorData.trials(t).vPos = data_raw.data(2,:)/CALIBRATE_POS;
    behaviorData.trials(t).hVel = data_raw.data(3,:)/CALIBRATE_VEL;
    behaviorData.trials(t).vVel = data_raw.data(4,:)/CALIBRATE_VEL;
         
end