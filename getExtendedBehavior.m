function [data] = getExtendedBehavior (data,supPath)


path = [supPath '\' data.info.task '\behavior\' ...
    data.info.extended_behavior_shadow_name];
behavior = importdata(path);


for t = 1:length(data.trials)
    assert(strcmp(data.trials(t).maestro_name,...
        behavior.trials(t).maestro_name))
    
    data.trials(t).hPos = behavior.trials(t).hPos;
    data.trials(t).vPos = behavior.trials(t).vPos;
    data.trials(t).hVel = behavior.trials(t).hVel;
    data.trials(t).vVel = behavior.trials(t).vVel;
    
    data.trials(t).extended_trial_begin = behavior.trials(t).extended_trial_begin;
    data.trials(t).extended_blink_begin = behavior.trials(t).extended_blink_begin;
    data.trials(t).extended_blink_end = behavior.trials(t).extended_blink_end;
    data.trials(t).extended_saccade_begin = behavior.trials(t).extended_saccade_begin;
    data.trials(t).extended_saccade_end = behavior.trials(t).extended_saccade_end;
    
end

end

