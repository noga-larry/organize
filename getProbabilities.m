function [probabilities,match_p] = getProbabilities (data,ind,varargin)
% getProbabilities - Extract target reward probabilities from the given data based on trial names.
%
% This function finds all target reward probabilities in the 'data' structure based on the trial names.
%
% INPUTS:
%   data: A structure containing session trials. Each element in the 'trials' field of 'data'
%         is expected to have a field 'name' representing the trial name.
%   ind (optional): Indices of the trials to consider for matching. Default is 1:length(data.trials).
%   varargin (optional): Additional optional arguments passed to the 'trialTypeGetter' function.
%
% OUTPUTS:
%   probabilities: A cell array containing all unique target reward probabilities found in 'data.trials'.
%   match_p: A cell array of the same size as 'data.trials' containing the matched target probabilities
%            for each trial. If 'data' represents a choice session, 'match_p' will be a 2 x N cell array,
%            where N is the number of trials. The first row represents the first target probability in
%            the trial name, and the second row represents the second target probability.
%
if nargin>1
    [probabilities,match_p] = trialTypeGetter('(?<=P)[0-9]*|(?<=p)[0-9]*', data,ind,varargin{:});
else
    [probabilities,match_p] = trialTypeGetter('(?<=P)[0-9]*|(?<=p)[0-9]*', data);
end