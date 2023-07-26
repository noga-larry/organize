function [velocities,match_v] = getVelocities (data)
% getVelocities - Extract target velocities from the given data based on trial names.
%
% This function finds all target velocities in the 'data' structure based on the trial
% names. It uses a regular expression to identify velocities from trial names and returns
% an array of all unique velocities and an array containing the matched velocities for
% each trial in 'data.trials'. If 'data' represents a choice session, the dimensions of
% 'match_v' will be 2 x length(data.trials), where the first row represents the first
% target velocity in the trial name, and the second row represents the second target velocity.
%
% INPUTS:
%   data: A structure containing session trials. Each element in the 'trials' field of 'data'
%         is expected to have a field 'name' representing the trial name.
%
% OUTPUTS:
%   velocities: An array containing all unique target velocities found in 'data.trials'.
%   match_v: An array of the same size as 'data.trials' containing the matched target velocities
%            for each trial. If 'data' represents a choice session, 'match_v' will be a 2 x N array,
%            where N is the number of trials. The first row represents the first target velocity in
%            the trial name, and the second row represents the second target velocity.
%
expression = '(?<=v)[0-9]*'; 
[match_v,~] = regexp({data.trials.name},expression,'match','split','forceCellOutput');
match_v = reshape([match_v{:}],length(match_v{1}),length(match_v));
match_v =  cellfun(@str2double,match_v);
velocities = unique(match_v);
velocities = sort(velocities);
