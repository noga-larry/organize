function [probabilities,match_p] = getProbabilities (data,ind,varargin)
% This function finds all target reward probabilities in data based on
% trial names.
% Inputs:     data           A structure containig session trials
%             ind            An optional variable, if
% Outputs:    probabilities  Cell array of all probabilites
%             match_p        Cell array in the length of data.trials
%                            containing the probabilities in each trial. If
%                            data is a choice session match_p's diminsions
%                            will be 2xlength(data.trials). The first row
%                            represents the first target in the name and
%                            the second row the second target.

if nargin==1
    ind=1:length(data.trials);
elseif nargin>2
    assert(isnumeric(ind))
end

p = inputParser;
defaultOmitNonIndexed = false;
addOptional(p,'omitNonIndexed',defaultOmitNonIndexed,@islogical);

parse(p,varargin{:})
omitNonIndexed = p.Results.omitNonIndexed;

expression = '(?<=P)[0-9]*|(?<=p)[0-9]*'; 
[match_p_tmp,~] = regexp({data.trials(ind).name},expression,'match','split','forceCellOutput');

if any(cellfun(@isempty,match_p_tmp))
    disp('Contain trial with no probability')
    probabilities = {};
    match_p = nan(length(ind),1);    
    return
end
match_p_tmp = reshape([match_p_tmp{:}],length(match_p_tmp{1}),length(match_p_tmp));
match_p_tmp =  cellfun(@str2double,match_p_tmp);
match_p = nan(size(match_p_tmp,1),length(data.trials));
match_p(:,ind) = match_p_tmp;
probabilities = unique(match_p);
probabilities(isnan(probabilities)) = [];
probabilities = sort(probabilities);

if omitNonIndexed
    match_p(isnan(match_p)) = [];
end
