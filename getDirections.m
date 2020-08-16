function [directions,match_d] = getDirections (data,ind)
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

if ~exist('ind','var')
    ind=1:length(data.trials);
end

expression = '(?<=d)[0-9]*'; 
[match_d_tmp,~] = regexp({data.trials(ind).name},expression,'match','split','forceCellOutput');
match_d_tmp = reshape([match_d_tmp{:}],length(match_d_tmp{1}),length(match_d_tmp));
match_d_tmp =  cellfun(@str2double,match_d_tmp);
match_d = nan(size(match_d_tmp,1),length(data.trials));
match_d(:,ind) = match_d_tmp
directions = unique(match_d);
directions(isnan(directions)) = [];
directions = sort(directions);
