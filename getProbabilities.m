function [probabilities,match_p] = getProbabilities (data)
% This function finds all target reward probabilities in data based on
% trial names.
% Inputs:     data           A structure containig session trials
% Outputs:    probabilities  Cell array of all probabilites
%             match_p        Cell array in the length of data.trials
%                            containing the probabilities in each trial. If
%                            data is a choice session match_p's diminsions
%                            will be 2xlength(data.trials). The first row
%                            represents the first target in the name and
%                            the second row the second target.

expression = '(?<=P)[0-9]*|(?<=p)[0-9]*'; 
[match_p,~] = regexp({data.trials.name},expression,'match','split','forceCellOutput');
match_p = reshape([match_p{:}],length(match_p{1}),length(match_p));
probabilities = uniqueRowsCA({match_p{:}}');
probabilities = natsortfiles(probabilities');
probabilities(cellfun('isempty',probabilities)) = [];