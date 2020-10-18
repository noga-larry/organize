function task = getTrialType(data_raw)
    if ~isempty(regexp(data_raw.trialname,'vs'))
        task = 'choice';
    elseif ~isempty(regexp(data_raw.trialname,'v[1-9]*s'))
        task = 'pursuit_8_dir_75and25';
    elseif ~isempty(regexp(data_raw.trialname,'v'))
        task = 'pursuit_8_dir_75and25';
    else
        task = 'saccade_8_dir_75and25';
    end
end