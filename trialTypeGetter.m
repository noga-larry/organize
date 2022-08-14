function [groups,match_vec] = trialTypeGetter(expression, data,ind,varargin)
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

if nargin==2
    ind=1:length(data.trials);
elseif nargin>3
    assert(isnumeric(ind))
end

if ischar(ind) && strcmp(ind,'all')
   ind = 1:length(data.trials);
end

if isempty(ind)
    warning('Empty set of indices!')
    groups = nan;
    match_vec = nan;
    return
end


p = inputParser;
defaultOmitNonIndexed = false;
addOptional(p,'omitNonIndexed',defaultOmitNonIndexed,@islogical);

parse(p,varargin{:})
omitNonIndexed = p.Results.omitNonIndexed;

[match_vec_tmp,~] = regexp({data.trials(ind).name},expression,'match','split','forceCellOutput');

if any(cellfun(@isempty,match_vec_tmp))
    warning('Error in determining trial type')
    groups = {};
    match_vec = nan(1,length(ind));    
    return
end
match_vec_tmp = reshape([match_vec_tmp{:}],length(match_vec_tmp{1}),length(match_vec_tmp));

isNumeric = ~any(isnan(cellfun(@str2double,match_vec_tmp)));
if isNumeric
    match_vec_tmp =  cellfun(@str2double,match_vec_tmp);
    match_vec = nan(size(match_vec_tmp,1),length(data.trials));
else
    match_vec = cell(size(match_vec_tmp,1),length(data.trials));
end

match_vec(:,ind) = match_vec_tmp;

if isNumeric
    groups = match_vec(~isnan(match_vec));
    groups = unique(match_vec);
    groups = sort(groups);
else
    groups = match_vec(~cellfun(@isempty,match_vec));
    groups = uniqueRowsCA(groups');
end

if omitNonIndexed
    match_vec(:, setdiff(1:length(data.trials),ind)) = [];
end