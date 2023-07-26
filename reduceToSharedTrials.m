function [data1,data2] = reduceToSharedTrials(data1,data2)

% reduceToSharedTrials Reduce input data structures to contain only shared trials.
%
% This function takes two input data structures 'data1' and 'data2' that are assumed
% to have fields 'trials', each containing an array of structs representing trials.
% Each struct in the 'trials' array is assumed to have a field 'maestro_name' which
% stores the name of the trial.
%
% INPUTS:
%   data1: The first input data structure.
%   data2: The second input data structure.
%
% OUTPUTS:
%   data1: Reduced data structure containing only the trials that are present in
%          both 'data1' and 'data2'. The trials not present in both datasets are
%          removed from the 'trials' field of 'data1'.
%   data2: Reduced data structure containing only the trials that are present in
%          both 'data1' and 'data2'. The trials not present in both datasets are
%          removed from the 'trials' field of 'data2'.

sharedTrials = intersect({data1.trials.maestro_name},...
    {data2.trials.maestro_name});

Match = cellfun(@(x) ismember(x, sharedTrials), {data1.trials.maestro_name}, 'UniformOutput', 0);
data1.trials = data1.trials(find(cell2mat(Match)));
Match = cellfun(@(x) ismember(x, sharedTrials), {data2.trials.maestro_name}, 'UniformOutput', 0);
data2.trials = data2.trials(find(cell2mat(Match)));
assert(length(data1.trials)==length(data2.trials))

    