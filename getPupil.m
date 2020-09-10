function [data] = getPupil (data,maestroPath);

for t=1:length(data.trials)
data_raw = readcxdata (  [maestroPath '\' data.info.monkey '\'  data.info.session ...
   '\' data.trials(t).maestro_name]);

trace = data_raw.data(5,:);
trace = removesSaccades(trace,data.trials(t).blinkBegin,data.trials(t).blinkEnd);
data.trials(t).pupil = data_raw.data(5,:);

end
