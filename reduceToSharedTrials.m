function [data1,data2] = reduceToSharedTrials(data1,data2)

sharedTrials = intersect({data1.trials.maestro_name},...
        {data2.trials.maestro_name});

    Match = cellfun(@(x) ismember(x, sharedTrials), {data1.trials.maestro_name}, 'UniformOutput', 0);
    data1.trials = data1.trials(find(cell2mat(Match)));
    Match = cellfun(@(x) ismember(x, sharedTrials), {data2.trials.maestro_name}, 'UniformOutput', 0);
    data2.trials = data2.trials(find(cell2mat(Match)));
    assert(length(data1.trials)==length(data2.trials))

    