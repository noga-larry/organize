function match_op = getPreviousOutcomes(data,ind,varargin)

% getPreviousOutcomes - Calculate the previous outcomes for each trial in the data.
%
% This function calculates the previous outcomes for each trial in the 'data' structure based on the
% 'previous_completed' field. If the 'previous_completed' field of a trial is true, the outcome of the
% previous trial is assigned to the current trial. If 'previous_completed' is false, or if it's the first
% trial, the current trial is assigned 'NaN' as the previous outcome.
%
% INPUTS:
%   data: A structure containing session trials. Each element in the 'trials' field of 'data' is expected
%         to have a field 'previous_completed' representing whether the previous trial was completed.
%   ind (optional): Indices of the trials to consider for matching. Default is 1:length(data.trials).
%   varargin (optional): Additional optional arguments passed to the 'inputParser' function.
%                        'omitNonIndexed' can be used to exclude non-indexed trials from the output.
%
% OUTPUTS:
%   match_op: An array containing the previous outcomes for each trial in 'data.trials'. If 'omitNonIndexed'
%             is true, 'match_op' will have the same size as 'ind', containing the previous outcomes for the
%             specified trials. Otherwise, 'match_op' will have the same size as 'data.trials', with 'NaN'
%             values for non-indexed trials.

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

match_o = getOutcome(data);
match_op_tmp = nan(1,length(data.trials));
for i=2:length(data.trials)
    if data.trials(i).previous_completed
        match_op_tmp(i) = match_o(i-1);
    else
        match_op_tmp(i) = nan;
    end
end

if omitNonIndexed
    match_op = match_op_tmp(ind);    
else
    match_op = nan(1,length(data.trials));
    match_op(ind) = match_op_tmp(ind);
end
    