function [directions,match_d] = getDirections (data)

expression = '(?<=d)[0-9]*'; 
[match_d,~] = regexp({data.trials.name},expression,'match','split','forceCellOutput');
match_d = reshape([match_d{:}],length(match_d{1}),length(match_d));
directions = uniqueRowsCA({match_d{:}}');
directions = natsortfiles(directions');
directions(cellfun('isempty',directions)) = [];