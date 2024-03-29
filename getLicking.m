function [data,FLAG_CROSS] = getLicking (data,maestroPath)

THRESHOLD = 1000;
FLAG_CROSS = false;
for t=1:length(data.trials)
    extended = importdata (  [maestroPath '\'  data.info.monkey '\'  data.info.session ...
        '\extend_trial\' data.trials(t).maestro_name '.mat']);   
    data.trials(t).lick = extended.lick;
    data.trials(t).extended_trial_begin = extended.trial_begin_ms;
    if any(data.trials(t).lick >THRESHOLD)
        FLAG_CROSS = true;
    end
end
