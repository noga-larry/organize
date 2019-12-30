function [data] = getExtendedBehavior (data,maestroPath);


b_0 = data.extended_caliberation.b_0;
b_1 = data.extended_caliberation.b_1;

for t=1:length(data.trials)
    extended = importdata (  [maestroPath '\'  data.info.session ...
        '\extend_trial\' data.trials(t).maestro_name '.mat']);
    data.trials(t).extended_hPos = b_0(1)+b_1(1)*extended.eyeh;
    data.trials(t).extended_vPos = b_0(2)+b_1(2)*extended.eyev;
    data.trials(t).extended_hVel = diff(data.trials(t).extended_hPos)*1000;
    data.trials(t).extended_vVel = diff(data.trials(t).extended_vPos)*1000;
    
end