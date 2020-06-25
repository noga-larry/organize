function task = getTrialType(data_raw)
if ~isempty(regexp(data_raw.trialname,'vs'))
    task = 'choice';
elseif ~isempty(regexp(data_raw.trialname,'v[1-9]*s'))
    task = 'speed';
elseif ~isempty(regexp(data_raw.trialname,'v'))
    task = 'pursuit';
else
    task = 'saccade';
    
end
end