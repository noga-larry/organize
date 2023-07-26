function [sizes,match_s] = getRewardSize(data,ind,varargin)

% getRewardSize - Extract target reward sizes from the given data based on trial names.
%
% This function finds all target reward sizes in the 'data' structure based on the
% trial names. 
%
% INPUTS:
%   data: A structure containing session trials. Each element in the 'trials' field of
%         'data' is expected to have a field 'name' representing the trial name.
%   ind (optional): Indices of the trials to consider for matching. Default is 1:length(data.trials).
%   varargin (optional): Additional optional arguments passed to the 'trialTypeGetter' function.
%
% OUTPUTS:
%   sizes: A cell array containing all unique target reward sizes found in 'data.trials'.
%   match_s: A cell array of the same size as 'data.trials' containing the matched target sizes
%            for each trial. If 'data' represents a choice session, 'match_s' will be a 2 x N
%            cell array, where N is the number of trials. The first row represents the first
%            target size in the trial name, and the second row represents the second target size.


if nargin>1
    [sizes,match_s] = trialTypeGetter(expression, data,ind,varargin{:});
else
    [sizes,match_s] = ...
        trialTypeGetter(expression, data);
end

