function [groups,match_vec] = trialTypeGetter(expression, data,ind,varargin)
% TRIALTYPEGETTER Extract trial types based on a given regular expression.
% This funcion is called by other functions like getDirecctions,
% getProbabilities, getVelocities, etc.
%
% INPUTS:
%   expression: Regular expression to match trial names against.
%   data: Struct containing trial information with fields 'trials' that is an array of structs.
%         Each struct in the 'trials' array should have a field 'name' representing the trial name.
%   ind (optional): Indices of the trials to consider for matching. Default is 1:length(data.trials).
%   varargin (optional): Additional optional arguments.
%       'omitNonIndexed': Logical flag to exclude non-indexed trials from match_vec. Default is false.
%
% OUTPUTS:
%   groups: Unique trial types found in the 'data.trials' that match the provided regular expression.
%           If the matches are numeric, the output will be a sorted numeric array.
%           If the matches are non-numeric strings, the output will be a cell array of unique rows.
%   match_vec: A matrix or cell array containing the matched values for each trial in 'data.trials'.
%              Rows correspond to different trial types, and columns correspond to trials in 'data.trials'.
%              If the matches are numeric, match_vec will be a numeric matrix.
%              If the matches are non-numeric strings, match_vec will be a cell array.

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