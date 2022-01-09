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
if nargin>1
    [probabilities,match_p] = trialTypeGetter('(?<=P)[0-9]*|(?<=p)[0-9]*', data,ind,varargin{:});
else
    [probabilities,match_p] = trialTypeGetter('(?<=P)[0-9]*|(?<=p)[0-9]*', data);
end