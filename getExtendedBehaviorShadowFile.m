function [extendedBehaviorData] = getExtendedBehaviorShadowFile(data,MaestroPath)

SD = 10; %ms

extendedBehaviorData.info = data.info;
   
b_0 = data.extended_caliberation.b_0;
b_1 = data.extended_caliberation.b_1;
for t=1:length(data.trials)
    
     extended = importdata([MaestroPath  '\'  data.info.monkey '\' ...
        data.info.session '\extend_trial\' ...
        data.trials(t).maestro_name '.mat']);
    
     
    extendedBehaviorData.trials(t).hPos = b_0(1)+b_1(1)*extended.eyeh';
    extendedBehaviorData.trials(t).vPos = b_0(2)+b_1(2)*extended.eyev';
    extendedBehaviorData.trials(t).hVel = diff(gaussSmooth(data.trials(t).hPos,SD))*1000;
    extendedBehaviorData.trials(t).vVel = diff(gaussSmooth(data.trials(t).vPos,SD))*1000;
    extendedBehaviorData.trials(t).extended_trial_begin = extended.trial_begin_ms;
         
end