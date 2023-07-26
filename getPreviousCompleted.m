function data = getPreviousCompleted(data,MaestroPath)
% This function adds a fields to the strcture data, 'previous_completed' that
% is 1 if the previous trial was completed and 0 else.


THRESHOLD = 1000;

for t = 1:length(data.trials)
    extended = importdata (  [MaestroPath '\'  data.info.session ...
        '\extend_trial\' data.trials(t).maestro_name '.mat']);
    data.trials(t).previous_completed = any(extended.rwd(1:extended.trial_begin_ms) > THRESHOLD);
    plot(extended.rwd); hold on
end