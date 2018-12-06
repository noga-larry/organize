function [directions,match_d] = getDirections (data)
% This function finds all target directions in data based on
% trial names.
% Inputs:     data           A structure containig session trials
% Outputs:    directions     Cell array of all directions
%             match_d        Cell array in the length of data.trials
%                            containing the directions in each trial. If
%                            data is a choice session match_d's diminsions
%                            will be 2xlength(data.trials). The first row
%                            represents the first target in the name and
%                            the second row the second target.
expression = '(?<=d)[0-9]*'; 
[match_d,~] = regexp({data.trials.name},expression,'match','split','forceCellOutput');
match_d = reshape([match_d{:}],length(match_d{1}),length(match_d));
directions = uniqueRowsCA({match_d{:}}');
directions = natsortfiles(directions');
directions(cellfun('isempty',directions)) = [];