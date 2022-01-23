function data = getBehavior (data,supPath)

path = [supPath '\' data.info.task '\behavior\' ...
    data.info.behavior_shadow_name];
behavior = importdata(path);

for t = 1:length(data.trials)
    assert(strcmp(data.trials(t).maestro_name,...
        behavior.trials(t).maestro_name))
    data.trials(t).hPos = behavior.trials(t).hPos;
    data.trials(t).vPos = behavior.trials(t).vPos;
    data.trials(t).hVel = behavior.trials(t).hVel;
    data.trials(t).vVel = behavior.trials(t).vVel;
end

end
