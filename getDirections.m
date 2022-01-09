function [directions,match_d] = getDirections (data,ind,varargin)
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

[directions,match_d] = trialTypeGetter('(?<=P)[0-9]*|(?<=p)[0-9]*', data,ind,varargin{:})

