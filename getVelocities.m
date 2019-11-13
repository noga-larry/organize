function [velocities,match_v] = getVelocities (data)
% This function finds all target velocities in data based on
% trial names.
% Inputs:     data           A structure containig session trials
% Outputs:    velocities     Cell array of all velocities
%             match_v        Cell array in the length of data.trials
%                            containing the velocities in each trial. If
%                            data is a choice session match_v's diminsions
%                            will be 2xlength(data.trials). The first row
%                            represents the first target in the name and
%                            the second row the second target.
expression = '(?<=v)[0-9]*'; 
[match_v,~] = regexp({data.trials.name},expression,'match','split','forceCellOutput');
match_v = reshape([match_v{:}],length(match_v{1}),length(match_v));
match_v =  cellfun(@str2double,match_v);
velocities = unique(match_v);
velocities = sort(velocities);
