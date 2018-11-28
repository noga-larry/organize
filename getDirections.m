function [directions,match_d] = getDirections (data)

expression = '(?<=d)[0-9]*'; 
[match_d,~] = regexp({data.trials.name},expression,'match','split','forceCellOutput','once');
directions = uniqueRowsCA(match_d');
directions = natsortfiles(directions');
directions(cellfun('isempty',directions)) = [];