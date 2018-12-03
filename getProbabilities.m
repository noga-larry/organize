function [probabilities,match_p] = getProbabilities (data)

expression = '(?<=P)[0-9]*|(?<=p)[0-9]*'; 
[match_p,~] = regexp({data.trials.name},expression,'match','split','forceCellOutput');
match_p = reshape([match_p{:}],length(match_p{1}),length(match_p));
probabilities = uniqueRowsCA({match_p{:}}');
probabilities = natsortfiles(probabilities');
probabilities(cellfun('isempty',probabilities)) = [];