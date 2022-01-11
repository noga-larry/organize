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

p = inputParser;
defaultOmitNonIndexed = false;
addOptional(p,'omitNonIndexed',defaultOmitNonIndexed,@islogical);

parse(p,varargin{:})
omitNonIndexed = p.Results.omitNonIndexed;

[match_vec_emp,~] = regexp({data.trials(ind).name},expression,'match','split','forceCellOutput');

if any(cellfun(@isempty,match_vec_emp))
    disp('Error in determining trial type')
    groups = {};
    match_vec = nan(length(ind),1);    
    return
end
match_vec_emp = reshape([match_vec_emp{:}],length(match_vec_emp{1}),length(match_vec_emp));
match_vec_emp =  cellfun(@str2double,match_vec_emp);
match_vec = nan(size(match_vec_emp,1),length(data.trials));
match_vec(:,ind) = match_vec_emp;
groups = unique(match_vec);
groups(isnan(groups)) = [];
groups = sort(groups);

if omitNonIndexed
    match_vec(:, setdiff(1:length(data.trials),ind)) = [];
end